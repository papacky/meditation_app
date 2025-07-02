# 瞑想記録アプリ（meditation_app）

## 概要
Google Driveの音楽ファイルを再生し、その再生をトリガーに瞑想記録を自動でカレンダーに記録するWebアプリです。
本アプリはRuby on Rails + PostgreSQLを使用し、Renderでのクラウド運用を前提としています。

---

## 7月1日の実施内容・操作手順

1. **プロジェクト構成の確認**
   - `\\wsl.localhost\Ubuntu\home\ytpacky/projects/contest/meditation_app` ディレクトリにRailsアプリが存在していることを確認。
2. **PostgreSQLのインストール（Ubuntu/WSL）**
   - 下記コマンドでインストール。
     ```sh
     sudo apt update
     sudo apt install postgresql postgresql-contrib libpq-dev
     ```
3. **Gemfileの編集**
   - PostgreSQL用の `pg`、Google認証用の `omniauth-google-oauth2`、Google Drive API用の `google-api-client` をGemfileに追記。
     ```ruby
     gem 'pg'
     gem 'omniauth-google-oauth2'
     gem 'google-api-client', '~> 0.53.0'
     ```
   - 追記後、`bundle install` を実行。
4. **config/database.ymlの修正**
   - adapter: postgresql など、PostgreSQL用に設定。
5. **データベース作成・マイグレーション**
   ```sh
   bin/rails db:create
   bin/rails db:migrate
   ```
6. **GitHub連携のトラブル対応**
   - リモートリポジトリの設定（`git remote add origin <URL>`）
   - `git push -u origin main` でアップロード
7. **Google Cloud Platform準備**
   - [Google Cloud Console](https://console.cloud.google.com/) にアクセスし、新規プロジェクトを作成
   - 左メニュー「APIとサービス」→「ライブラリ」から「Google Drive API」を検索し、有効化
   - 左メニュー「APIとサービス」→「認証情報」→「認証情報を作成」→「OAuthクライアントID」を選択
   - アプリケーションの種類は「ウェブアプリ」を選択
   - 承認済みのリダイレクトURIに `http://localhost:3000/auth/google_oauth2/callback` を追加（本番時はRenderのURLも追加）
   - 作成後、クライアントIDとクライアントシークレットを控える
   - これらの情報はRailsアプリの環境変数やcredentialsに設定予定

---

## 7月2日の実施内容・操作手順

### Google Drive連携の実装完了 ✅

1. **Google OAuth認証の実装**
   - `config/initializers/omniauth.rb` でGoogle OAuth設定
   - `app/controllers/auth_controller.rb` で認証処理
   - `app/services/google_drive_service.rb` でGoogle Drive API連携

2. **音楽ファイル管理機能**
   - `app/controllers/music_controller.rb` で音楽ファイル一覧・再生
   - `app/views/music/index.html.erb` で音楽ライブラリUI
   - `app/views/music/play.html.erb` で音楽再生・瞑想記録作成UI

3. **瞑想記録機能**
   - `app/controllers/meditation_records_controller.rb` で記録管理
   - `app/views/meditation_records/index.html.erb` で記録一覧・統計表示

4. **UI/UX改善**
   - Tailwind CSSを追加してモダンなデザイン
   - レスポンシブ対応
   - フラッシュメッセージ表示

### 環境変数設定手順

1. **開発環境での環境変数設定**
   ```bash
   # .envファイルを作成（gitignoreに追加済み）
   echo "GOOGLE_CLIENT_ID=your_google_client_id_here" > .env
   echo "GOOGLE_CLIENT_SECRET=your_google_client_secret_here" >> .env
   ```

2. **dotenv-rails gemの追加（推奨）**
   ```ruby
   # Gemfileに追加
   gem 'dotenv-rails', groups: [:development, :test]
   ```

3. **アプリケーション起動**
   ```bash
   bin/rails server
   ```

### 動作確認手順

1. **Google OAuth認証**
   - アプリにアクセス → "Google Driveに接続" ボタンをクリック
   - Googleアカウントで認証 → 音楽ライブラリ画面に遷移

2. **音楽ファイル表示**
   - Google Driveの音楽ファイル（mp3, wav, flac, m4a, aac, ogg）が一覧表示

3. **音楽再生・瞑想記録**
   - 音楽ファイルの "再生" ボタンをクリック
   - 音楽再生画面で "瞑想開始" → "瞑想終了" → "記録を保存"

4. **記録確認**
   - "瞑想記録を見る" で記録一覧と統計を確認

---

## 今後の全体計画（詳細）

1. **Google Drive連携の実装** ✅ 完了
   - `omniauth-google-oauth2`でGoogleアカウント認証機能を実装
   - `google-api-client`でGoogle Driveの音楽ファイル一覧を取得・表示
   - 認証フローとAPI連携のコントローラー・ルーティング実装

2. **カレンダー記録機能の実装** ✅ 完了
   - 日付ごとに瞑想記録（回数・時間など）を保存できるモデル・コントローラー・ビューの作成
   - カレンダー形式での記録表示、合計回数・日数・時間の集計

3. **音楽再生UIの実装** ✅ 完了
   - Google Driveの音楽ファイルをアプリ内で再生（audioタグ等）
   - 再生ボタン押下時に自動で瞑想記録を保存

4. **Renderへのデプロイ** 🔄 次回実施予定
   - Renderの無料プランを利用し、アプリをクラウド公開
   - PostgreSQLクラウドDBの設定
   - 本番用Google OAuthリダイレクトURIの追加

5. **追加機能の実装** 🔄 今後の拡張予定
   - カリキュラム振り返り、メモ帳、ご褒美機能など
   - UI/UXの改善、スマホ対応

---

## 備考
- 本番運用ではPostgreSQLを使用
- Google Drive APIの利用にはGoogle Cloud Platformでの設定が必要
- Renderの無料プランはスリープ制限あり
- 環境変数は必ず設定してからアプリを起動すること

---

ご不明点や追加要望があれば、READMEを随時更新してください。 