# onepassword-operator

helmの `--set-file` でインストールしない場合、あらかじめjsonといいながらjsonをbase64した文字列を加工したやつを入れる必要がある。

```bash
cat 1password-credentials.json | base64 | tr '/+' '_-' | tr -d '=' | tr -d '\n' > 1password-credentials.json.b64enc
```
