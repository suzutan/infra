# freesia k8s

自宅で動かしている k8s の公開できるマニフェストを記載しています。

一部コマンドは ubuntu 環境で動かすことを前提としています。

## initialize

kubeadm を用いた k8s の setup

```bash
(
  cd _setup
  make install init
)
```

```bash
(
  cd init
  make apply
)
```
