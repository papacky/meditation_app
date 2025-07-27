#!/bin/bash

# Fly.io デプロイスクリプト
set -e

echo "🚀 Fly.io へのデプロイを開始します..."

# Fly.io CLIがインストールされているかチェック
if ! command -v fly &> /dev/null; then
    echo "❌ Fly.io CLIがインストールされていません。"
    echo "インストール方法: https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

# ログイン状態をチェック
if ! fly auth whoami &> /dev/null; then
    echo "🔐 Fly.ioにログインしてください..."
    fly auth login
fi

# アプリが存在しない場合は作成
if ! fly apps list | grep -q "meditation-app"; then
    echo "📱 アプリを作成しています..."
    fly apps create meditation-app --org personal
fi

# PostgreSQLデータベースが存在しない場合は作成
if ! fly postgres list | grep -q "meditation-app-db"; then
    echo "🗄️ PostgreSQLデータベースを作成しています..."
    fly postgres create --name meditation-app-db --region nrt
    echo "🔗 データベースをアプリに接続しています..."
    fly postgres attach meditation-app-db --app meditation-app
else
    echo "🗄️ PostgreSQLデータベースは既に存在します"
fi

# データベースボリュームが存在しない場合は作成
if ! fly volumes list | grep -q "meditation_app_data"; then
    echo "💾 データベースボリュームを作成しています..."
    fly volumes create meditation_app_data --size 1 --region nrt
fi

# シークレットを設定（必要に応じて）
echo "🔒 環境変数を設定しています..."
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)

# デプロイ実行
echo "🚀 デプロイを実行しています..."
fly deploy

echo "✅ デプロイが完了しました！"
echo "🌐 アプリURL: https://meditation-app.fly.dev" 