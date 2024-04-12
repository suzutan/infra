# migrate-pvc

k8s を構築し直したときに、古い PVC のデータを新しい PVC に引き継ぐときのコマンドメモ

```bash
cd /export
kubectl scale -n argocd sts/argocd-application-controller --replicas=0
kubectl -n minio scale statefulset/minio-pool-0 --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=minio-data0-minio-pool-0-0-pvc-c58ba968-de08-4c95-b2dc-36f711b68aea
# 新しくk8sを作成して発行されたディレクトリ名
new=minio-data0-minio-pool-0-0-pvc-e8f8bf15-38d5-4d94-a1d0-25d58b362695
mv $new ${new}.tmp
mv $old $new
)
kubectl -n minio  scale statefulset/minio-pool-0 --replicas=1

kubectl scale -n argocd sts/argocd-application-controller --replicas=0
kubectl scale -n temporis deployment/prometheus-operator --replicas=0
kubectl scale -n temporis statefulset/prometheus-prometheus --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-prometheus-prometheus-db-prometheus-prometheus-0-pvc-72df90c0-a86e-41c6-8989-9400059d26ff
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-prometheus-prometheus-db-prometheus-prometheus-0-pvc-f26698ef-1480-45c9-848b-8912e7491dc1
mv $new ${new}.tmp2
mv $old $new
)

kubectl scale -n temporis deployment/grafana --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-grafana-data-pvc-a245becb-6945-48b0-b416-36bbc98abbae
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-grafana-data-pvc-87718f2a-fef4-4c3f-8ea4-befd0eefa4c7
mv $new ${new}.tmp2
mv $old $new
)
# kubectl scale deployment/grafana --replicas=1


kubectl scale -n asf deployment/asf --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=asf-archisteamfarm-config-pvc-82ffdfd8-4e69-4887-b425-49068fcd02ba
# 新しくk8sを作成して発行されたディレクトリ名
new=asf-archisteamfarm-config-pvc-bfd34c6d-1a67-4f3c-b5aa-791764ed6160
mv $new ${new}.tmp2
mv $old $new
)



kubectl scale -n argocd sts/argocd-application-controller --replicas=1

```
