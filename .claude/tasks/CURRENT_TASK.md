# Task: stepCA + step-issuer構成の作成

**開始時刻**: 2025-12-25
**ステータス**: In Progress

## 目的

YubikeyにRoot CA秘密鍵を保存したCA証明書ペアと、署名用のIntermediate CA証明書を使用して、Kubernetes上にstepCA + step-issuerを構成する。

## 前提条件

### 既に作成済みのCA証明書
- **Root CA**: Yubikeyのslot 9cに秘密鍵を保存
  - 証明書: `root-ca.crt`
  - 秘密鍵: `yubikey:slot-id=9c` (パスフレーズ保護)
  - 有効期限: 87600h (10年)
- **Intermediate CA**: K8sで署名用
  - 証明書: `intermediate-ca.crt`
  - 秘密鍵: `intermediate-ca.key` (パスフレーズ保護)
  - 有効期限: 43800h (5年)
  - Root CAで署名済み

### 既存のインフラストラクチャ
- cert-manager v1.19.2がデプロイ済み
- 1Password Operatorによるsecrets管理
- ArgoCD GitOps
- Traefik Ingress Controller

## タスクフェーズ

### Phase 1: 調査・設計 ✅
- [x] 既存cert-manager構成を確認
- [x] stepCAのデプロイメント方法を調査
- [x] step-issuerのインストール方法を調査
- [x] 必要なsecrets構成を設計

### Phase 2: Secrets準備 ✅
- [x] Intermediate CA証明書と秘密鍵を1Passwordに登録
- [x] Root CA証明書を1Passwordに登録（参照用）
- [x] Provisioner JWK鍵ペアを1Passwordに登録
- [x] OnePasswordItemマニフェストを作成

### Phase 3: stepCAデプロイ ✅
- [x] stepCA namespaceを作成
- [x] stepCA設定ファイル（ConfigMap）を作成
- [x] Helm values（step-certificates）を作成
- [x] kustomization.yamlでHelmチャートを統合

### Phase 4: step-issuerデプロイ ✅
- [x] Helm values（step-issuer）を作成
- [x] StepClusterIssuerマニフェストを作成
- [x] ArgoCD Applicationを作成

### Phase 5: 動作確認 ✅
- [x] StepClusterIssuerのcaBundleを実際のRoot CA証明書で更新
- [x] step-certificatesポッドが起動することを確認
- [x] step-issuerが正常に動作することを確認（StepClusterIssuer Ready）
- [ ] テスト証明書の発行
- [ ] GitリポジトリにPush
- [ ] ArgoCD同期を確認

## 進捗状況

### In Progress
- テスト完了、Git commit準備中

### Completed Steps
#### Phase 1: 調査・設計
- cert-manager v1.19.2がデプロイ済みであることを確認
- 既存のClusterIssuer構成を確認（harvestasya, letsencrypt-prod）
- 1Password経由のsecrets管理パターンを確認
- stepCAのHelmチャート構成を調査（smallstep/step-certificates）
- step-issuerのHelmチャート構成を調査（smallstep/step-issuer）
- ca.json設定ファイルの構造を理解
- 既存Intermediate CA証明書を使用する方法を確認

#### Phase 2-4: 実装
- 1PasswordにCA証明書、秘密鍵、Provisioner JWK鍵を登録
- 全てのKubernetesマニフェストを作成
- Helmチャート統合をkustomizeで実現
- ArgoCD Application作成

#### Phase 5: 動作確認
- StepClusterIssuer Ready状態確認（status.conditions.type=Ready, status=True）
- テスト証明書発行成功:
  - Subject: CN=test.harvestasya.org
  - Issuer: CN=Harvestasya Intermediate CA
  - 有効期限: 24時間
  - Signature Algorithm: ecdsa-with-SHA256
- Secret作成確認（ca.crt, tls.crt, tls.key）

### Modified Files
- `.claude/tasks/CURRENT_TASK.md` - タスク管理ファイル
- `freesia/manifests/step-ca/namespace.yaml` - step-ca namespace
- `freesia/manifests/step-ca/secret-ca-config.yaml` - ca.json/defaults.json OnePasswordItem（ConfigMap→Secret→OnePasswordItemに変更）
- `freesia/manifests/step-ca/secret-step-certificates-certs.yaml` - CA証明書用OnePasswordItem
- `freesia/manifests/step-ca/secret-step-certificates-secrets.yaml` - Intermediate CA秘密鍵用OnePasswordItem
- `freesia/manifests/step-ca/secret-step-certificates-ca-password.yaml` - CA秘密鍵パスフレーズ用OnePasswordItem
- `freesia/manifests/step-ca/secret-step-issuer-provisioner.yaml` - Provisioner JWK用OnePasswordItem
- `freesia/manifests/step-ca/values-step-certificates.yaml` - step-certificates Helm values
- `freesia/manifests/step-ca/values-step-issuer.yaml` - step-issuer Helm values
- `freesia/manifests/step-ca/stepclusterissuer.yaml` - StepClusterIssuer CRD（caBundleを更新）
- `freesia/manifests/step-ca/kustomization.yaml` - Kustomize設定
- `freesia/manifests/argocd-apps/step-ca.yaml` - ArgoCD Application
- `freesia/manifests/argocd-apps/kustomization.yaml` - step-ca.yamlを追加

### Decisions Made
#### デプロイ戦略
1. **Helmチャートベースのデプロイ**:
   - step-certificatesとstep-issuerの公式Helmチャートを使用
   - Kustomizeでラップしてカスタマイズ（CLAUDE.mdの推奨パターン）
   - `existingSecrets: true` を設定して既存CA証明書を使用

2. **Namespace**: `step-ca`

3. **必要なSecrets（1Password管理）**:
   - `step-certificates-certs`: root-ca.crt, intermediate-ca.crt（PEMバンドル）
   - `step-certificates-secrets`: intermediate-ca.key
   - `step-certificates-ca-password`: Intermediate CA秘密鍵のパスフレーズ
   - `step-certificates-config`: ca.json, defaults.json設定ファイル

4. **ca.json設定構造**:
   ```json
   {
     "root": "/home/step/certs/root_ca.crt",
     "crt": "/home/step/certs/intermediate_ca.crt",
     "key": "/home/step/secrets/intermediate_ca_key",
     "address": ":9000",
     "dnsNames": ["step-certificates.step-ca.svc.cluster.local"],
     "authority": {
       "provisioners": [
         {
           "type": "JWK",
           "name": "admin",
           ...
         }
       ]
     }
   }
   ```

5. **step-issuer構成**:
   - cert-manager統合用のStepClusterIssuerを作成
   - CA URL: `https://step-certificates.step-ca.svc.cluster.local:9000`

#### 参照リソース
- [Install step-ca Guide](https://smallstep.com/docs/step-ca/installation/)
- [step-certificates Helm Chart](https://github.com/smallstep/helm-charts/blob/master/step-certificates/README.md)
- [Deploy Kubernetes Step Issuer](https://smallstep.com/docs/certificate-manager/kubernetes-tls/kubernetes-step-issuer/)
- [step-issuer GitHub](https://github.com/smallstep/step-issuer)
- [Deploy Intermediate CA Tutorial](https://smallstep.com/docs/tutorials/intermediate-ca-new-ca/)

### Blockers
#### 解決済み
1. **問題**: step-certificatesポッドが起動しない - `secret "step-certificates-config" not found`
   - **原因**: Helmチャートが`existingSecrets.configAsSecret: true`の設定でSecretを期待していたが、ConfigMapを作成していた
   - **修正**: `configmap-ca-config.yaml`を`secret-ca-config.yaml`に変更し、kind: ConfigMapをkind: Secretに変更

2. **問題**: secret-ca-config.yamlに機密情報が含まれていた（public repo公開不可）
   - **原因**: ca.jsonのencryptedKey（暗号化されたProvisioner秘密鍵）や内部構成情報が平文で含まれていた
   - **セキュリティリスク**:
     - 暗号化鍵のブルートフォース攻撃リスク
     - 内部アーキテクチャの露出
   - **修正**: secret-ca-config.yamlをOnePasswordItemに変更し、ca.jsonとdefaults.jsonを1Password（UUID: 2n33wjnxjubdch4z4im4y75xb4）で管理

3. **問題**: StepClusterIssuer初期化エラー - "context deadline exceeded"
   - **原因**: StepClusterIssuerのURLが`https://step-certificates.step-ca.svc.cluster.local:9000`を指定していたが、ServiceはPort 443を公開（targetPort 9000にマッピング）
   - **修正**: URLから`:9000`を削除し、デフォルトHTTPSポート443を使用

4. **問題**: Provisioner秘密鍵の復号エラー - "error decrypting provisioner key with provided password"
   - **原因**: 既存JWKのパスワードが不明
   - **修正**: 新しいJWK鍵ペアを`step crypto jwk create`で作成（kid: VjFDb15x_MB3BOIE3p90ucyEBF4q-sG-5InHhClzqyg）

5. **問題**: StepClusterIssuer初期化エラー - "compact JWE format must have five parts"
   - **原因**: ca.jsonのencryptedKeyがJWE JSON Serialization形式（{protected, encrypted_key, iv, ciphertext, tag}）だったが、step-caはJWE Compact Serialization（5パートをドットで連結）を期待
   - **修正**: provisioner-jwk.keyから手動でCompact形式に変換（protected.encrypted_key.iv.ciphertext.tag）
   - **1Password更新**: ca.json（UUID: 2n33wjnxjubdch4z4im4y75xb4）、provisioner-password.txt（UUID: djxs6dcd2ydczf2l4yqbz5oady）

### Next Steps
1. ~~StepClusterIssuerのcaBundleを更新~~ ✅ 完了
2. ~~ConfigMapをSecretに修正~~ ✅ 完了
3. ~~secret-ca-config.yamlをOnePasswordItemに変更（セキュリティ対応）~~ ✅ 完了
4. ~~step-certificatesポッドが起動することを確認~~ ✅ 完了
5. ~~step-issuerが正常に動作することを確認~~ ✅ 完了（StepClusterIssuer Ready状態）
6. ~~StepClusterIssuerのURL/caBundle/kid修正~~ ✅ 完了
7. ~~JWK provisioner再作成とencryptedKey形式修正~~ ✅ 完了
8. ~~テスト証明書の発行~~ ✅ 完了（Harvestasya Intermediate CAで正しく署名された証明書を発行確認）
9. 変更をGitにコミット・プッシュ
10. ArgoCD同期を確認
