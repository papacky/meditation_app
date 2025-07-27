# Fly.io デプロイ手順

## 前提条件

1. **Fly.io CLIのインストール**
   ```bash
   # macOS
   brew install flyctl
   
   # Windows
   powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
   
   # Linux
   curl -L https://fly.io/install.sh | sh
   ```

2. **Fly.ioアカウントの作成**
   - [Fly.io](https://fly.io) でアカウントを作成
   - クレジットカードの登録が必要（無料枠あり）

## デプロイ手順

### 1. ログイン
```bash
fly auth login
```

### 2. 自動デプロイスクリプトの実行
```bash
./bin/fly-deploy.sh
```

### 3. 手動デプロイ（オプション）

#### アプリの作成
```bash
fly apps create meditation-app --org personal
```

#### データベースボリュームの作成
```bash
fly volumes create meditation_app_data --size 1 --region nrt
```

#### 環境変数の設定
```bash
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)
```

#### デプロイ実行
```bash
fly deploy
```

## デプロイ後の確認

### アプリの状態確認
```bash
fly status
```

### ログの確認
```bash
fly logs
```

### アプリへのアクセス
- URL: https://meditation-app.fly.dev
- ヘルスチェック: https://meditation-app.fly.dev/health

## トラブルシューティング

### よくある問題

1. **ポートエラー**
   - Dockerfileでポート8080を使用していることを確認
   - fly.tomlのinternal_portが8080に設定されていることを確認

2. **データベース接続エラー**
   - DATABASE_URL環境変数が正しく設定されていることを確認
   - PostgreSQLデータベースが利用可能であることを確認

3. **アセットプリコンパイルエラー**
   - RAILS_MASTER_KEYが正しく設定されていることを確認
   - 本番環境でのアセットプリコンパイルが成功していることを確認

### ログの確認
```bash
# リアルタイムログ
fly logs --follow

# 特定のエラーを検索
fly logs | grep ERROR
```

## 設定のカスタマイズ

### リージョンの変更
`fly.toml`の`primary_region`を変更：
```toml
primary_region = "hkg"  # 香港
primary_region = "syd"  # シドニー
primary_region = "lhr"  # ロンドン
```

### メモリの調整
`fly.toml`の`memory_mb`を変更：
```toml
memory_mb = 2048  # 2GB
```

### スケーリング
```bash
# インスタンス数を増やす
fly scale count 2

# メモリを増やす
fly scale memory 2048
```

## コスト管理

### 無料枠の制限
- 3つのアプリまで
- 月間160時間の実行時間
- 3GBのストレージ

### 使用量の確認
```bash
fly billing show
```

## セキュリティ

### 環境変数の管理
```bash
# シークレットの設定
fly secrets set SECRET_KEY=value

# シークレットの確認
fly secrets list

# シークレットの削除
fly secrets unset SECRET_KEY
```

### SSL証明書
Fly.ioは自動的にSSL証明書を管理します。 