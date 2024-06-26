# migrate-pvc

k8s を構築し直したときに、古い PVC のデータを新しい PVC に引き継ぐときのコマンドメモ

prepare

```bash
mount.nfs nas.sv.ssa.suzutan.jp:freesia /export

cd /export
kubectl scale -n argocd sts/argocd-application-controller --replicas=0
```

minio

```bash
kubectl -n minio scale statefulset/minio-pool-0 --replicas=0
du -h -d 1 . | grep minio
(
# 前から使っていたPVCのディレクトリ名
old=archived-minio-data0-minio-pool-0-0-pvc-2fc8fd12-3eda-429d-a64f-2ad630166c1f
# 新しくk8sを作成して発行されたディレクトリ名
new=minio-data0-minio-pool-0-0-pvc-3f7a9f84-593b-4b6c-82bd-81d677d958bb
mv $new ${new}.tmp
mv $old $new
)
du -h -d 1 . | grep minio
kubectl -n minio  scale statefulset/minio-pool-0 --replicas=1
```

temporis

```bash
#--------------------
# prometheus
kubectl scale -n temporis statefulset/prometheus --replicas=0
du -h -d 1 . | grep prometheus
(
# 前から使っていたPVCのディレクトリ名
old=temporis-prometheus-data-prometheus-0-pvc-b823f5a0-df90-4b28-b4f7-59f2289afb54
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-prometheus-data-prometheus-0-pvc-3df3a447-6113-4378-913d-1464953df6f5
mv $new ${new}.tmp2
mv $old $new
)
du -h -d 1 . | grep prometheus
kubectl scale -n temporis statefulset/prometheus --replicas=1
stern -n temporis prometheus-0

#--------------------
# grafana
kubectl scale -n temporis deployment/grafana --replicas=0
du -h -d 1 . | grep grafana
(
# 前から使っていたPVCのディレクトリ名
old=temporis-grafana-data-pvc-6d57982d-56f0-4b18-967d-f74a7aed44e3
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-grafana-data-pvc-2cbe3d9f-acc6-4a70-bf88-41ee5ae484bf
mv $new ${new}.tmp2
mv $old $new
)
du -h -d 1 . | grep grafana
kubectl scale -n temporis deployment/grafana --replicas=1
stern -n temporis grafana

#--------------------
# influxdb2
kubectl scale -n temporis sts/influxdb2 --replicas=0
du -h -d 1 . | grep influxdb2
(
# 前から使っていたPVCのディレクトリ名
old=temporis-influxdb2-pvc-951c0cd4-3bfc-41f5-9c0f-50f6aeb1f825
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-influxdb2-pvc-11678697-eb95-49fc-a58c-7a89964a4fec
mv $new ${new}.tmp2
mv $old $new
)
du -h -d 1 . | grep influxdb2
kubectl scale -n temporis sts/influxdb2 --replicas=1
stern -n temporis influxdb2
```

asf

```bash
kubectl scale -n asf deployment/asf --replicas=0
du -h -d 1 . | grep asf
(
# 前から使っていたPVCのディレクトリ名
old=asf-archisteamfarm-config-pvc-0e520f41-8d85-4630-ba1f-93a853b2c8cf
# 新しくk8sを作成して発行されたディレクトリ名
new=asf-archisteamfarm-config-pvc-d475b571-c527-474b-b7ec-48224a60c6a6
mv $new ${new}.tmp2
mv $old $new
)
du -h -d 1 . | grep asf
```

authentik

```bash
kubectl scale -n authentik sts/authentik-postgresql --replicas=0
kubectl scale -n authentik sts/authentik-redis-master --replicas=0
du -h -d 1 . | grep authentik
(
# 前から使っていたPVCのディレクトリ名
old=authentik-data-authentik-postgresql-0-pvc-48ecefe1-1ae4-4ddc-b89d-d34a2844b88a
# 新しくk8sを作成して発行されたディレクトリ名
new=authentik-data-authentik-postgresql-0-pvc-58ed1135-4e91-426e-8127-5bd418c1bc8b
mv $new ${new}.tmp2
mv $old $new
)
(
# 前から使っていたPVCのディレクトリ名
old=authentik-redis-data-authentik-redis-master-0-pvc-67f5bfba-418e-4f10-b91b-13b918c269ed
# 新しくk8sを作成して発行されたディレクトリ名
new=authentik-redis-data-authentik-redis-master-0-pvc-92e66260-d69f-40d4-8655-360dc4dd0379
mv $new ${new}.tmp2
mv $old $new
)
du -h -d 1 . | grep authentik
```

kubectl scale -n argocd sts/argocd-application-controller --replicas=1
