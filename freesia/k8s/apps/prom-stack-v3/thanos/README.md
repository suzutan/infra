# thanos

banzaicloud の thanos chart つかって thanos 永続化を試す

```bash
kubectl create ns thanos
helm upgrade --install -n thanos thanos banzaicloud-stable/thanos -f values.yaml
```
