# migrate-pvc

k8s を構築し直したときに、古い PVC のデータを新しい PVC に引き継ぐときのコマンドメモ

```bash
mount.nfs nas.sv.ssa.suzutan.jp:freesia /export

cd /export
kubectl scale -n argocd sts/argocd-application-controller --replicas=0
kubectl -n minio scale statefulset/minio-pool-0 --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=minio-data0-minio-pool-0-0-pvc-e8f8bf15-38d5-4d94-a1d0-25d58b362695
# 新しくk8sを作成して発行されたディレクトリ名
new=minio-data0-minio-pool-0-0-pvc-2a12a162-ebc4-4ad9-9e82-36ceabe8d1dd
mv $new ${new}.tmp
mv $old $new
)
kubectl -n minio  scale statefulset/minio-pool-0 --replicas=1

kubectl scale -n argocd sts/argocd-application-controller --replicas=0
kubectl scale -n temporis deployment/prometheus-operator --replicas=0
kubectl scale -n temporis statefulset/prometheus-prometheus --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-prometheus-prometheus-db-prometheus-prometheus-0-pvc-bbfc9b90-baee-486c-8d64-a563bf5098f6
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-prometheus-data-prometheus-0-pvc-b823f5a0-df90-4b28-b4f7-59f2289afb54
mv $new ${new}.tmp2
mv $old $new
)

kubectl scale -n temporis deployment/grafana --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-grafana-data-pvc-87718f2a-fef4-4c3f-8ea4-befd0eefa4c7
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-grafana-data-pvc-6d57982d-56f0-4b18-967d-f74a7aed44e3
mv $new ${new}.tmp2
mv $old $new
)
# kubectl scale deployment/grafana --replicas=1


kubectl scale -n asf deployment/asf --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=asf-archisteamfarm-config-pvc-bfd34c6d-1a67-4f3c-b5aa-791764ed6160
# 新しくk8sを作成して発行されたディレクトリ名
new=asf-archisteamfarm-config-pvc-0e520f41-8d85-4630-ba1f-93a853b2c8cf
mv $new ${new}.tmp2
mv $old $new
)


kubectl scale -n authentik sts/authentik-postgresql --replicas=0
kubectl scale -n authentik sts/authentik-redis-master --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=archived-authentik-data-authentik-postgresql-0-pvc-a10e2c55-48a1-42bf-9103-409d0092d865
# 新しくk8sを作成して発行されたディレクトリ名
new=authentik-data-authentik-postgresql-0-pvc-48ecefe1-1ae4-4ddc-b89d-d34a2844b88a
mv $new ${new}.tmp2
mv $old $new
)
(
# 前から使っていたPVCのディレクトリ名
old=authentik-redis-data-authentik-redis-master-0-pvc-b3e28659-eea1-48d2-b928-468936e1aa34
# 新しくk8sを作成して発行されたディレクトリ名
new=authentik-redis-data-authentik-redis-master-0-pvc-b94859b8-8197-4768-b9e5-de2ad5476c2e
mv $new ${new}.tmp2
mv $old $new
)


kubectl scale -n argocd sts/argocd-application-controller --replicas=1

```
