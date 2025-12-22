# output "mx_record_ids" {
#   description = "IDs of created MX records"
#   value = [
#     cloudflare_record.gw_mx_0.id,
#     cloudflare_record.gw_mx_1.id,
#     cloudflare_record.gw_mx_2.id,
#     cloudflare_record.gw_mx_3.id,
#     cloudflare_record.gw_mx_4.id,
#   ]
# }

# output "mx_record_hostnames" {
#   description = "Hostnames of created MX records"
#   value = [
#     cloudflare_record.gw_mx_0.hostname,
#     cloudflare_record.gw_mx_1.hostname,
#     cloudflare_record.gw_mx_2.hostname,
#     cloudflare_record.gw_mx_3.hostname,
#     cloudflare_record.gw_mx_4.hostname,
#   ]
# }

# output "spf_record_id" {
#   description = "ID of SPF TXT record"
#   value       = var.enable_spf ? cloudflare_record.gw_txt_spf[0].id : null
# }

# output "domain_verify_record_id" {
#   description = "ID of domain verification TXT record"
#   value       = cloudflare_record.gw_domain_verify.id
# }

# output "dkim_record_ids" {
#   description = "Map of DKIM record names to IDs"
#   value       = { for k, v in cloudflare_record.gw_dkim : k => v.id }
# }

# output "dmarc_record_id" {
#   description = "ID of DMARC TXT record"
#   value       = var.dmarc_record != "" ? cloudflare_record.gw_dmarc[0].id : null
# }
