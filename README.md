# 瞑想記録アプリ（meditation_app）

## 概要
Google Driveの音楽ファイルを再生し、その再生をトリガーに瞑想記録を自動でカレンダーに記録するWebアプリです。
本アプリはRuby on Rails + PostgreSQLを使用し、Renderでのクラウド運用を前提としています。

---

## ここまでの操作手順

1. **リポジトリのクローン・ディレクトリ移動**
   ```sh
   cd /home/ytpacky/projects/contest/meditation_app
   ```
2. **PostgreSQLのインストール（Ubuntu/WSL）**
   ```sh
   sudo apt update
   sudo apt install postgresql postgresql-contrib libpq-dev
   ```
3. **Gemfileにpgを追加し、bundle install**
   ```sh
   gem 'pg'
   bundle install
   ```
4. **config/database.ymlをPostgreSQL用に修正**
   - adapter: postgresql
   - username: postgres
   - database名などを適宜設定
5. **データベース作成・マイグレーション**
   ```sh
   bin/rails db:create
   bin/rails db:migrate
   ```

---

## 今後の全体計画

1. **Google Drive連携**
   - Googleアカウント認証（OAuth2）
   - 音楽ファイル一覧の取得・表示
2. **カレンダー記録機能の実装**
   - 日付ごとに瞑想記録（回数・時間など）を保存
   - カレンダー形式で表示
   - 合計回数・日数・時間の集計
3. **音楽再生UIの実装**
   - Google Driveの音楽ファイルをアプリ内で再生
   - 再生ボタン押下時に自動で瞑想記録を保存
4. **Renderへのデプロイ**
   - Renderの無料プランを利用し、アプリをクラウド公開
   - PostgreSQLクラウドDBの設定
5. **追加機能の実装**
   - カリキュラム振り返り、メモ帳、ご褒美機能など

---

## 備考
- 本番運用ではPostgreSQLを使用
- Google Drive APIの利用にはGoogle Cloud Platformでの設定が必要
- Renderの無料プランはスリープ制限あり

---

ご不明点や追加要望があれば、READMEを随時更新してください。
