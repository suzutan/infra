# migrate-pvc

k8sを構築し直したときに、古いPVCのデータを新しいPVCに引き継ぐときのコマンドメモ

```bash
cd /export
(
# 前から使っていたPVCのディレクトリ名
old=minio-data0-minio-pool-0-0-pvc-83333033-90a9-481b-a784-8dd204864f47
# 新しくk8sを作成して発行されたディレクトリ名
new=minio-data0-minio-pool-0-0-pvc-741d8ab4-e44e-480b-84c5-01739c0d2bda
kubectl scale statefulset/minio-pool-0 --replicas=0
mv $new ${new}.tmp
mv $old $new
kubectl scale statefulset/minio-pool-0 --replicas=1
)


kubectl scale -n argocd sts/argocd-application-controller --replicas=0
k scale deploy prometheus-operator --replicas=0
kubectl scale statefulset/prometheus-prometheus --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-prometheus-prometheus-db-prometheus-prometheus-0-pvc-c3abcadc-7ba1-4199-80e1-dd6d2876da9c
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-prometheus-prometheus-db-prometheus-prometheus-0-pvc-a05602b4-eb0f-4685-8b5b-8b44a4445657
mv $new ${new}.tmp2
mv $old $new
)
kubectl scale -n argocd sts/argocd-application-controller --replicas=1

kubectl scale deployment/grafana --replicas=0
(
# 前から使っていたPVCのディレクトリ名
old=temporis-grafana-data-pvc-ab82346d-5bef-4abe-b41b-3e73fd0d2185
# 新しくk8sを作成して発行されたディレクトリ名
new=temporis-grafana-data-pvc-0d5834c3-ad62-4ff7-8695-dc7e5b4394c2
mv $new ${new}.tmp2
mv $old $new
)
kubectl scale deployment/grafana --replicas=1
kubectl scale -n argocd sts/argocd-application-controller --replicas=1

```
