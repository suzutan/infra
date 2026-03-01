"""
nanomdm-operator: Kubernetes CRD-based Apple MDM management operator.

Watches MDMProfile/MDMDevice/MDMCommand/MDMEnrollmentProfile CRs
and translates them into NanoMDM API calls.
"""

import asyncio
import base64
import hashlib
import json
import logging
import os
import plistlib
import uuid
from datetime import datetime, timezone

import httpx
import kopf
from aiohttp import web
from kubernetes import client as k8s_client
from kubernetes import config as k8s_config

logger = logging.getLogger("nanomdm-operator")

NANOMDM_URL = os.environ.get("NANOMDM_URL", "http://nanomdm:9000")
NANOMDM_API_KEY = os.environ.get("NANOMDM_API_KEY", "")
NAMESPACE = os.environ.get("OPERATOR_NAMESPACE", "nanomdm")
API_GROUP = "mdm.harvestasya.org"
API_VERSION = "v1alpha1"

# ---------------------------------------------------------------------------
# NanoMDM HTTP client
# ---------------------------------------------------------------------------

def _nanomdm_auth():
    return ("nanomdm", NANOMDM_API_KEY)


async def nanomdm_push(enrollment_id: str) -> dict:
    async with httpx.AsyncClient() as c:
        r = await c.get(
            f"{NANOMDM_URL}/v1/push/{enrollment_id}",
            auth=_nanomdm_auth(),
            timeout=30,
        )
        r.raise_for_status()
        return r.json()


async def nanomdm_enqueue(enrollment_id: str, command_plist: bytes) -> dict:
    async with httpx.AsyncClient() as c:
        r = await c.put(
            f"{NANOMDM_URL}/v1/enqueue/{enrollment_id}",
            content=command_plist,
            auth=_nanomdm_auth(),
            timeout=30,
        )
        r.raise_for_status()
        return r.json()


async def nanomdm_upload_pushcert(cert_pem: str, key_pem: str) -> dict:
    combined = f"{cert_pem}\n{key_pem}".encode()
    async with httpx.AsyncClient() as c:
        r = await c.put(
            f"{NANOMDM_URL}/v1/pushcert",
            content=combined,
            auth=_nanomdm_auth(),
            timeout=30,
        )
        r.raise_for_status()
        return r.json()


# ---------------------------------------------------------------------------
# Plist command builders
# ---------------------------------------------------------------------------

def build_install_profile_command(mobileconfig_bytes: bytes) -> bytes:
    cmd = {
        "Command": {
            "RequestType": "InstallProfile",
            "Payload": mobileconfig_bytes,
        },
        "CommandUUID": str(uuid.uuid4()),
    }
    return plistlib.dumps(cmd)


def build_remove_profile_command(identifier: str) -> bytes:
    cmd = {
        "Command": {
            "RequestType": "RemoveProfile",
            "Identifier": identifier,
        },
        "CommandUUID": str(uuid.uuid4()),
    }
    return plistlib.dumps(cmd)


def build_simple_command(request_type: str, params: dict | None = None) -> bytes:
    command = {"RequestType": request_type}
    if params:
        if request_type == "DeviceInformation" and "queries" in params:
            command["Queries"] = params["queries"]
        elif request_type == "DeviceLock" and "pin" in params:
            command["PIN"] = params["pin"]
        elif request_type == "EraseDevice" and "pin" in params:
            command["PIN"] = params["pin"]
    cmd = {
        "Command": command,
        "CommandUUID": str(uuid.uuid4()),
    }
    return plistlib.dumps(cmd)


# ---------------------------------------------------------------------------
# Kubernetes helpers
# ---------------------------------------------------------------------------

def _now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _get_custom_api() -> k8s_client.CustomObjectsApi:
    try:
        k8s_config.load_incluster_config()
    except k8s_config.ConfigException:
        k8s_config.load_kube_config()
    return k8s_client.CustomObjectsApi()


def _get_core_api() -> k8s_client.CoreV1Api:
    try:
        k8s_config.load_incluster_config()
    except k8s_config.ConfigException:
        k8s_config.load_kube_config()
    return k8s_client.CoreV1Api()


def _list_devices(namespace: str, match_labels: dict) -> list:
    api = _get_custom_api()
    devices = api.list_namespaced_custom_object(
        group=API_GROUP,
        version=API_VERSION,
        namespace=namespace,
        plural="mdmdevices",
    )
    result = []
    for d in devices.get("items", []):
        labels = d.get("metadata", {}).get("labels", {})
        if all(labels.get(k) == v for k, v in match_labels.items()):
            result.append(d)
    return result


def _resolve_mobileconfig(spec: dict, namespace: str) -> bytes | None:
    mc = spec.get("mobileconfig", {})
    if mc.get("inline"):
        return mc["inline"].encode("utf-8")
    if mc.get("configMapRef"):
        ref = mc["configMapRef"]
        api = _get_core_api()
        cm = api.read_namespaced_config_map(ref["name"], namespace)
        return cm.data.get(ref["key"], "").encode("utf-8")
    if mc.get("secretRef"):
        ref = mc["secretRef"]
        api = _get_core_api()
        secret = api.read_namespaced_secret(ref["name"], namespace)
        raw = secret.data.get(ref["key"], "")
        return base64.b64decode(raw)
    return None


# ---------------------------------------------------------------------------
# Webhook server for NanoMDM events
# ---------------------------------------------------------------------------

_webhook_app = web.Application()


async def _handle_webhook(request: web.Request) -> web.Response:
    try:
        data = await request.json()
    except Exception:
        return web.Response(status=400, text="invalid json")

    topic = data.get("topic", "")
    logger.info("webhook received: topic=%s", topic)

    if topic == "mdm.TokenUpdate":
        await _handle_token_update(data)
    elif topic == "mdm.CheckOut":
        await _handle_checkout(data)
    elif topic == "mdm.Connect":
        await _handle_command_result(data)

    return web.Response(text="ok")


async def _handle_token_update(data: dict):
    checkin = data.get("checkin_event", {})
    udid = checkin.get("udid", "")
    enrollment_id = checkin.get("enrollment_id", udid)
    tally = checkin.get("token_update_tally", 0)

    if not udid:
        return

    # Sanitize UDID for use as K8s resource name
    safe_name = f"device-{udid.lower().replace(':', '-')[:48]}"

    api = _get_custom_api()
    try:
        existing = api.get_namespaced_custom_object(
            group=API_GROUP,
            version=API_VERSION,
            namespace=NAMESPACE,
            plural="mdmdevices",
            name=safe_name,
        )
        # Update status
        existing.setdefault("status", {})
        existing["status"]["enrolled"] = True
        existing["status"]["lastSeenAt"] = _now_iso()
        if tally == 1:
            existing["status"]["enrolledAt"] = _now_iso()
        api.patch_namespaced_custom_object_status(
            group=API_GROUP,
            version=API_VERSION,
            namespace=NAMESPACE,
            plural="mdmdevices",
            name=safe_name,
            body={"status": existing["status"]},
        )
        logger.info("updated MDMDevice %s (tally=%d)", safe_name, tally)
    except k8s_client.ApiException as e:
        if e.status == 404:
            # Create new MDMDevice CR
            body = {
                "apiVersion": f"{API_GROUP}/{API_VERSION}",
                "kind": "MDMDevice",
                "metadata": {
                    "name": safe_name,
                    "namespace": NAMESPACE,
                    "labels": {
                        "mdm.harvestasya.org/group": "unassigned",
                    },
                    "annotations": {
                        "argocd.argoproj.io/compare-options": "IgnoreExtraneous",
                    },
                },
                "spec": {
                    "udid": udid,
                    "enrollmentId": enrollment_id,
                    "displayName": "",
                },
            }
            api.create_namespaced_custom_object(
                group=API_GROUP,
                version=API_VERSION,
                namespace=NAMESPACE,
                plural="mdmdevices",
                body=body,
            )
            # Set initial status
            api.patch_namespaced_custom_object_status(
                group=API_GROUP,
                version=API_VERSION,
                namespace=NAMESPACE,
                plural="mdmdevices",
                name=safe_name,
                body={
                    "status": {
                        "enrolled": True,
                        "enrolledAt": _now_iso(),
                        "lastSeenAt": _now_iso(),
                    }
                },
            )
            logger.info("created MDMDevice %s for UDID %s", safe_name, udid)
        else:
            raise


async def _handle_checkout(data: dict):
    checkin = data.get("checkin_event", {})
    udid = checkin.get("udid", "")
    if not udid:
        return
    safe_name = f"device-{udid.lower().replace(':', '-')[:48]}"
    api = _get_custom_api()
    try:
        api.patch_namespaced_custom_object_status(
            group=API_GROUP,
            version=API_VERSION,
            namespace=NAMESPACE,
            plural="mdmdevices",
            name=safe_name,
            body={
                "status": {
                    "enrolled": False,
                    "lastSeenAt": _now_iso(),
                    "conditions": [
                        {
                            "type": "Enrolled",
                            "status": "False",
                            "lastTransitionTime": _now_iso(),
                            "reason": "CheckedOut",
                            "message": "Device has unenrolled from MDM",
                        }
                    ],
                }
            },
        )
        logger.info("device %s checked out", safe_name)
    except k8s_client.ApiException:
        logger.warning("could not update checkout for %s", safe_name)


async def _handle_command_result(data: dict):
    ack = data.get("acknowledge_event", {})
    command_uuid = ack.get("command_uuid", "")
    status = ack.get("status", "")
    if not command_uuid:
        return
    logger.info("command result: uuid=%s status=%s", command_uuid, status)


_webhook_app.router.add_post("/webhook", _handle_webhook)


# ---------------------------------------------------------------------------
# kopf lifecycle
# ---------------------------------------------------------------------------

@kopf.on.startup()
async def startup_fn(settings, **kwargs):
    settings.posting.level = logging.WARNING
    settings.persistence.finalizer = "mdm.harvestasya.org/finalizer"

    # Start webhook server
    runner = web.AppRunner(_webhook_app)
    await runner.setup()
    site = web.TCPSite(runner, "0.0.0.0", 8080)
    await site.start()
    logger.info("webhook server started on :8080")

    # Upload APNs push certificate if available
    apns_cert = os.environ.get("APNS_CERT_PEM", "")
    apns_key = os.environ.get("APNS_KEY_PEM", "")
    if apns_cert and apns_key:
        try:
            result = await nanomdm_upload_pushcert(apns_cert, apns_key)
            logger.info("uploaded APNs push certificate: %s", result)
        except Exception as exc:
            logger.error("failed to upload APNs push certificate: %s", exc)


# ---------------------------------------------------------------------------
# MDMProfile controller
# ---------------------------------------------------------------------------

@kopf.on.create(API_GROUP, API_VERSION, "mdmprofiles")
@kopf.on.update(API_GROUP, API_VERSION, "mdmprofiles")
async def reconcile_profile(spec, name, namespace, status, patch, logger, **kwargs):
    logger.info("reconciling MDMProfile %s", name)
    patch.status["phase"] = "Distributing"

    # Resolve mobileconfig content
    mobileconfig = _resolve_mobileconfig(spec, namespace)
    if not mobileconfig:
        patch.status["phase"] = "Error"
        patch.status["conditions"] = [
            {
                "type": "Ready",
                "status": "False",
                "lastTransitionTime": _now_iso(),
                "reason": "MobileconfigNotFound",
                "message": "Could not resolve mobileconfig content",
            }
        ]
        return

    # Find matching devices
    selector = spec.get("deviceSelector", {})
    match_labels = selector.get("matchLabels", {})
    devices = _list_devices(namespace, match_labels)

    target_count = len(devices)
    installed_count = 0
    failed_count = 0
    device_statuses = []

    for device in devices:
        device_name = device["metadata"]["name"]
        enrollment_id = device.get("spec", {}).get("enrollmentId", "")
        if not enrollment_id:
            enrollment_id = device.get("spec", {}).get("udid", "")
        if not enrollment_id:
            device_statuses.append(
                {"deviceRef": device_name, "status": "Skipped", "error": "no enrollmentId"}
            )
            failed_count += 1
            continue

        try:
            command = build_install_profile_command(mobileconfig)
            await nanomdm_enqueue(enrollment_id, command)
            device_statuses.append(
                {"deviceRef": device_name, "status": "Installed", "installedAt": _now_iso()}
            )
            installed_count += 1
        except Exception as exc:
            device_statuses.append(
                {"deviceRef": device_name, "status": "Failed", "error": str(exc)}
            )
            failed_count += 1

    phase = "Distributed" if failed_count == 0 else "Error"
    if target_count == 0:
        phase = "Pending"

    patch.status["phase"] = phase
    patch.status["targetDevices"] = target_count
    patch.status["installedDevices"] = installed_count
    patch.status["failedDevices"] = failed_count
    patch.status["lastDistributedAt"] = _now_iso()
    patch.status["deviceStatuses"] = device_statuses
    patch.status["conditions"] = [
        {
            "type": "Ready",
            "status": "True" if failed_count == 0 else "False",
            "lastTransitionTime": _now_iso(),
            "reason": "AllDevicesInstalled" if failed_count == 0 else "SomeDevicesFailed",
            "message": f"Profile sent to {installed_count}/{target_count} devices",
        }
    ]


@kopf.on.delete(API_GROUP, API_VERSION, "mdmprofiles")
async def delete_profile(spec, name, namespace, logger, **kwargs):
    if not spec.get("removeOnDelete", True):
        return

    identifier = spec.get("profileIdentifier", "")
    if not identifier:
        return

    selector = spec.get("deviceSelector", {})
    match_labels = selector.get("matchLabels", {})
    devices = _list_devices(namespace, match_labels)

    for device in devices:
        enrollment_id = device.get("spec", {}).get("enrollmentId", "")
        if not enrollment_id:
            enrollment_id = device.get("spec", {}).get("udid", "")
        if not enrollment_id:
            continue
        try:
            command = build_remove_profile_command(identifier)
            await nanomdm_enqueue(enrollment_id, command)
            logger.info("sent RemoveProfile %s to %s", identifier, enrollment_id)
        except Exception as exc:
            logger.error("failed to remove profile from %s: %s", enrollment_id, exc)


# ---------------------------------------------------------------------------
# MDMDevice controller
# ---------------------------------------------------------------------------

@kopf.on.update(API_GROUP, API_VERSION, "mdmdevices", field="metadata.labels")
async def device_labels_changed(spec, name, namespace, logger, **kwargs):
    """When device labels change, re-evaluate all MDMProfile CRs."""
    logger.info("device %s labels changed, re-evaluating profiles", name)
    api = _get_custom_api()
    profiles = api.list_namespaced_custom_object(
        group=API_GROUP,
        version=API_VERSION,
        namespace=namespace,
        plural="mdmprofiles",
    )
    for profile in profiles.get("items", []):
        profile_name = profile["metadata"]["name"]
        # Touch the profile to trigger reconciliation
        api.patch_namespaced_custom_object(
            group=API_GROUP,
            version=API_VERSION,
            namespace=namespace,
            plural="mdmprofiles",
            name=profile_name,
            body={
                "metadata": {
                    "annotations": {
                        "mdm.harvestasya.org/last-reconcile": _now_iso(),
                    }
                }
            },
        )


# ---------------------------------------------------------------------------
# MDMCommand controller
# ---------------------------------------------------------------------------

@kopf.on.create(API_GROUP, API_VERSION, "mdmcommands")
async def execute_command(spec, name, namespace, patch, logger, **kwargs):
    logger.info("executing MDMCommand %s", name)
    patch.status["phase"] = "Queued"
    patch.status["queuedAt"] = _now_iso()

    # Resolve target devices
    devices = []
    if spec.get("deviceRef", {}).get("name"):
        api = _get_custom_api()
        try:
            device = api.get_namespaced_custom_object(
                group=API_GROUP,
                version=API_VERSION,
                namespace=namespace,
                plural="mdmdevices",
                name=spec["deviceRef"]["name"],
            )
            devices = [device]
        except k8s_client.ApiException as e:
            patch.status["phase"] = "Failed"
            patch.status["conditions"] = [
                {
                    "type": "Complete",
                    "status": "False",
                    "lastTransitionTime": _now_iso(),
                    "reason": "DeviceNotFound",
                    "message": f"Device {spec['deviceRef']['name']} not found",
                }
            ]
            return
    elif spec.get("deviceSelector", {}).get("matchLabels"):
        devices = _list_devices(namespace, spec["deviceSelector"]["matchLabels"])

    if not devices:
        patch.status["phase"] = "Failed"
        patch.status["conditions"] = [
            {
                "type": "Complete",
                "status": "False",
                "lastTransitionTime": _now_iso(),
                "reason": "NoDevices",
                "message": "No matching devices found",
            }
        ]
        return

    # Build and send command
    cmd_spec = spec.get("command", {})
    request_type = cmd_spec.get("requestType", "")
    params = cmd_spec.get("params")
    command_plist = build_simple_command(request_type, params)

    patch.status["phase"] = "Sent"
    patch.status["sentAt"] = _now_iso()

    success = True
    for device in devices:
        enrollment_id = device.get("spec", {}).get("enrollmentId", "")
        if not enrollment_id:
            enrollment_id = device.get("spec", {}).get("udid", "")
        if not enrollment_id:
            continue
        try:
            result = await nanomdm_enqueue(enrollment_id, command_plist)
            cmd_uuid = result.get("command_uuid", "")
            patch.status["commandUUID"] = cmd_uuid
        except Exception as exc:
            logger.error("failed to send command to %s: %s", enrollment_id, exc)
            success = False

    if success:
        patch.status["phase"] = "Completed"
        patch.status["completedAt"] = _now_iso()
        patch.status["conditions"] = [
            {
                "type": "Complete",
                "status": "True",
                "lastTransitionTime": _now_iso(),
                "reason": "CommandSent",
                "message": f"{request_type} sent to {len(devices)} device(s)",
            }
        ]
    else:
        patch.status["phase"] = "Failed"
        patch.status["conditions"] = [
            {
                "type": "Complete",
                "status": "False",
                "lastTransitionTime": _now_iso(),
                "reason": "SendFailed",
                "message": "Failed to send command to one or more devices",
            }
        ]


# ---------------------------------------------------------------------------
# MDMEnrollmentProfile controller
# ---------------------------------------------------------------------------

@kopf.on.create(API_GROUP, API_VERSION, "mdmenrollmentprofiles")
@kopf.on.update(API_GROUP, API_VERSION, "mdmenrollmentprofiles")
async def reconcile_enrollment_profile(spec, name, namespace, patch, logger, **kwargs):
    logger.info("reconciling MDMEnrollmentProfile %s", name)

    server_url = spec.get("serverURL", "")
    checkin_url = spec.get("checkInURL", server_url)
    scep_config = spec.get("scep", {})
    org = spec.get("organization", {})

    # Read SCEP challenge from secret if referenced
    scep_challenge = ""
    challenge_ref = scep_config.get("challenge", {}).get("secretRef")
    if challenge_ref:
        try:
            api = _get_core_api()
            secret = api.read_namespaced_secret(challenge_ref["name"], namespace)
            scep_challenge = base64.b64decode(
                secret.data.get(challenge_ref["key"], "")
            ).decode("utf-8")
        except Exception as exc:
            logger.error("failed to read SCEP challenge secret: %s", exc)

    # Generate enrollment mobileconfig
    scep_uuid = str(uuid.uuid4()).upper()
    mdm_uuid = str(uuid.uuid4()).upper()
    profile_uuid = str(uuid.uuid4()).upper()

    profile = {
        "PayloadContent": [
            {
                "PayloadContent": {
                    "Key Type": "RSA",
                    "Challenge": scep_challenge,
                    "Key Usage": 5,
                    "Keysize": scep_config.get("keySize", 2048),
                    "URL": scep_config.get("url", ""),
                    "Subject": [
                        [["O", org.get("name", "Harvestasya")]],
                        [["CN", "MDM Identity"]],
                    ],
                },
                "PayloadIdentifier": f"org.harvestasya.mdm.scep.{name}",
                "PayloadType": "com.apple.security.scep",
                "PayloadUUID": scep_uuid,
                "PayloadVersion": 1,
                "PayloadDisplayName": "MDM SCEP",
            },
            {
                "AccessRights": 8191,
                "CheckInURL": checkin_url,
                "CheckOutWhenRemoved": True,
                "IdentityCertificateUUID": scep_uuid,
                "ServerCapabilities": [
                    "com.apple.mdm.per-user-connections",
                    "com.apple.mdm.bootstraptoken",
                    "com.apple.mdm.token",
                ],
                "ServerURL": server_url,
                "SignMessage": True,
                "Topic": "",  # Set from APNs cert topic
                "PayloadIdentifier": f"org.harvestasya.mdm.mdm.{name}",
                "PayloadType": "com.apple.mdm",
                "PayloadUUID": mdm_uuid,
                "PayloadVersion": 1,
                "PayloadDisplayName": "MDM Configuration",
            },
        ],
        "PayloadDisplayName": org.get("description", "Harvestasya MDM"),
        "PayloadIdentifier": f"org.harvestasya.mdm.enrollment.{name}",
        "PayloadOrganization": org.get("name", "Harvestasya"),
        "PayloadType": "Configuration",
        "PayloadUUID": profile_uuid,
        "PayloadVersion": 1,
        "PayloadRemovalDisallowed": False,
    }

    profile_bytes = plistlib.dumps(profile)
    profile_hash = hashlib.sha256(profile_bytes).hexdigest()

    # Store as ConfigMap
    api = _get_core_api()
    cm_name = f"enrollment-{name}"
    cm_body = k8s_client.V1ConfigMap(
        metadata=k8s_client.V1ObjectMeta(name=cm_name, namespace=namespace),
        binary_data={"enrollment.mobileconfig": base64.b64encode(profile_bytes).decode()},
    )
    try:
        api.read_namespaced_config_map(cm_name, namespace)
        api.replace_namespaced_config_map(cm_name, namespace, cm_body)
    except k8s_client.ApiException as e:
        if e.status == 404:
            api.create_namespaced_config_map(namespace, cm_body)
        else:
            raise

    serving = spec.get("serving", {})
    path = serving.get("path", "/enroll")

    patch.status["profileHash"] = f"sha256:{profile_hash}"
    patch.status["lastGeneratedAt"] = _now_iso()
    patch.status["enrollmentURL"] = f"{server_url.rsplit('/mdm', 1)[0]}{path}"
    patch.status["conditions"] = [
        {
            "type": "Ready",
            "status": "True",
            "lastTransitionTime": _now_iso(),
            "reason": "ProfileGenerated",
            "message": f"Enrollment profile stored in ConfigMap {cm_name}",
        }
    ]
