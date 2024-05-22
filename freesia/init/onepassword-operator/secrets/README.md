# onepassword-operator

helmの `--set-file` でインストールしない場合、あらかじめjsonといいながらjsonをbase64した文字列を加工したやつを入れる必要がある。

```bash
cat secrets/1password-credentials.json | base64 | tr '/+' '_-' | tr -d '=' | tr -d '\n' > secrets/1password-credentials.json.b64enc
```
