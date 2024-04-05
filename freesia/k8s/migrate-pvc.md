# migrate-pvc

k8s を構築し直したときに、古い PVC のデータを新しい PVC に引き継ぐときのコマンドメモ

```bash
cd /export

kubectl -n minio scale statefulset/minio-pool-0 --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=minio-data0-minio-pool-0-0-pvc-741d8ab4-e44e-480b-84c5-01739c0d2bda
# 新しくk8sを作成して発行されたディレクトリ名
new=minio-data0-minio-pool-0-0-pvc-c5ea1512-cd52-418b-953f-c5fdfbd78241
mv $new ${new}.tmp
mv $old $new
)
kubectl -n minio  scale statefulset/minio-pool-0 --replicas=1

kubectl scale -n argocd sts/argocd-application-controller --replicas=0
kubectl scale -n temporis deployment/prometheus-operator --replicas=0
kubectl scale -n temporis statefulset/prometheus-prometheus --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-prometheus-prometheus-db-prometheus-prometheus-0-pvc-a05602b4-eb0f-4685-8b5b-8b44a4445657
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-prometheus-prometheus-db-prometheus-prometheus-0-pvc-72df90c0-a86e-41c6-8989-9400059d26ff
mv $new ${new}.tmp2
mv $old $new
)

kubectl scale -n temporis deployment/grafana --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-grafana-data-pvc-0d5834c3-ad62-4ff7-8695-dc7e5b4394c2
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-grafana-data-pvc-a245becb-6945-48b0-b416-36bbc98abbae
mv $new ${new}.tmp2
mv $old $new
)
# kubectl scale deployment/grafana --replicas=1


kubectl scale -n asf deployment/asf --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=asf-archisteamfarm-config-pvc-5ba2bf3d-2ef6-43b2-95df-488355c998a8
# 新しくk8sを作成して発行されたディレクトリ名
new=asf-archisteamfarm-config-pvc-82ffdfd8-4e69-4887-b425-49068fcd02ba
mv $new ${new}.tmp2
mv $old $new
)



kubectl scale -n argocd sts/argocd-application-controller --replicas=1

```
