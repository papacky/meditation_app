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
   # .envファイルを作成（gitignoreに追加済み）　7月2日実施
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

1. **Google OAuth認証**  7月2日実施
　　⇒【重要】OmniAuth 2.x系の仕様変更について（この修正が３時間できなかった！！）
　　　OmniAuth 2.x 以降、CSRF対策のため、デフォルトで「/auth/:provider」へのGET
　　　リクエストが許可されていません。この場合、config/initializers/omniauth.rb 
　　　に下記を追加することでGETも許可できます。
   - アプリにアクセス → "Google Driveに接続" ボタンをクリック
   - Googleアカウントで認証 → 音楽ライブラリ画面に遷移

2. **音楽ファイル表示**　 7月3日予定
   - Google Driveの音楽ファイル（mp3, wav, flac, m4a, aac, ogg）が一覧表示
   
   ＜7/3 実施結果＞   
・Google Drive APIの認証・アクセストークンの扱いで、セッション管理や有効期限切れ時の再認証処理に苦労した。
Google Driveのmp3ファイルを直接audioタグで再生できず、API経由でRailsサーバーからストリーミング配信する独自エンドポイント（/music/stream/:file_id）を新設した。
Google Driveの「uc?export=download」形式ではCORSや認証の壁があり、API経由でのファイル取得に切り替えた。
ファイル一覧取得時、Google DriveのAPIレスポンスの構造や、mp3ファイルのみを抽出するクエリの記述に試行錯誤した。
ファイルの共有設定や権限によって取得できないケースがあり、権限エラーのデバッグに時間を要した。
ストリーミング配信時、Content-TypeやRangeリクエストの扱いでaudioタグが正しく再生できるよう調整した。
ファイルIDやファイル名の扱いで、URLエンコードや日本語ファイル名の表示崩れに対応した。
エラー時のユーザー向けメッセージや、ファイルが取得できない場合のUI表示を丁寧に作り込んだ。


3. **音楽再生・瞑想記録**　7月3日予定
   - 音楽ファイルの "再生" ボタンをクリック
   - 音楽再生画面で "瞑想開始" → "瞑想終了" → "記録を保存"



   ＜7/3 実施結果＞
Google Drive APIを使ったファイルアップロード時、multipart/form-dataのリクエスト生成やAPI仕様の理解に苦労した。
アップロード後、Google Drive上で即時にファイルが反映されない場合があり、APIレスポンスの確認やリスト再取得のタイミング調整を行った。
アップロード時のファイル名重複や拡張子チェックなど、バリデーション処理の実装に細かい調整が必要だった。
Google Driveのフォルダ指定アップロードで、フォルダIDの取得や指定方法に手間取った。
アップロード後のファイル権限設定（自分のみ閲覧可など）を自動化するため、APIの権限設定エンドポイントを追加で呼び出した。
Rails側でアップロード進行中のローディング表示や、完了・失敗時のメッセージ表示を工夫した。
アップロード失敗時のエラー内容が分かりづらく、APIレスポンスの詳細をユーザーに分かりやすく伝えるよう改善した。
Google Drive APIのクォータ制限やエラー（429, 403等）に遭遇し、リトライ処理やエラーハンドリングを強化した。


4. **記録確認**　7月3日予定
   - "瞑想記録を見る" で記録一覧と統計を確認

   ＜7/3 実施結果＞
瞑想記録の一覧・詳細表示で、ユーザーごとに記録を正しく絞り込むため、Devise認証やuser_idの紐付けに苦労した。
記録詳細ページ（show.html.erb）が存在しなかったため、新規作成し、indexと同じ情報を分かりやすく表示するレイアウトを工夫した。
記録保存後にTurboによるリダイレクト問題が発生し、data: { turbo: false }の付与で解決した。
記録の編集・削除機能追加時、権限チェックや他ユーザーの記録を操作できないようにする実装に注意した。
記録がない場合や、アクセス権限がない場合のエラーハンドリング・メッセージ表示を丁寧に作り込んだ。
記録の並び順や表示件数の制御で、直近の記録が常に上に来るようにソート処理を調整した。
音楽ファイル名や再生リンクを記録詳細に表示する際、Google DriveのファイルIDとアプリ内の記録を正しく紐付ける処理に苦労した。
UI/UX面で、スマホ表示やレイアウト崩れ、情報の見やすさを何度も調整し、ユーザーが直感的に記録を確認できるよう改善した。


＜７/５修正内容＞
1. 瞑想記録編集画面の作成
app/views/meditation_records/edit.html.erb テンプレートを新規作成
編集ボタン押下時の「テンプレートが見つからない」エラーを解決
2. 削除機能の修正
Rails 7のTurbo対応：method: :delete → data: { turbo_method: :delete } に変更
削除ボタンが正常に動作するよう修正
3. セキュリティ強化
コントローラーでユーザー権限チェックを追加
他ユーザーの記録を操作できないよう制限
4. Google OAuth設定の改善
access_type: 'offline' と prompt: 'consent' を追加
リフレッシュトークンを確実に取得できるよう修正
5. トークンリフレッシュ機能の実装
GoogleDriveService にトークンリフレッシュメソッドを追加
Google OAuth2 APIを直接呼び出してアクセストークンを更新
6. 自動トークンリフレッシュの設定
音楽再生開始時・ページアクセス時に55分後の自動リフレッシュタイマーを設定
60分でのAPI切断問題を解決
7. デバッグ機能の追加
2分後のテスト用リフレッシュタイマー（開発環境用）
セッション状態確認ボタンと手動テストボタンを追加
8. 瞑想記録ページのレイアウト改善
「今月の集計」を3分割カードデザインに変更
総合計の統計カードと同じスタイルで統一
9. アイコンとデザインの統一
今月の集計と総合計のアイコンを統一（回数・時間・日数）
カードサイズ、フォント、マージンを完全に統一
10. エラーハンドリングとログ強化
認証時・トークンリフレッシュ時の詳細なログ出力を追加
成功・失敗時の適切なメッセージ表示とリダイレクト処理

ーーーー参考ーーーー
参考：長時間アクセスに備えたリフレッシュトークンの使い方
あなたのDriveのファイルを使うために、あなた自身のアクセストークン／リフレッシュトークンを発行し、長期間使う構成にしてください。

具体的な手順：
あなたがOAuth認証を実行 → Googleから access_token + refresh_token を取得

アプリに保存（サーバー側で安全に保管）

アクセストークンが期限切れ（1時間程度）になったら、リフレッシュトークンを使って再取得

取得した新しいアクセストークンで、Drive APIからファイルを取得／再生

🔐 注意点：リフレッシュトークンの有効性
Googleの仕様として、

リフレッシュトークンは初回の認証時に1回だけ発行

同じユーザー・同じクライアントIDで何度も認証しても、新しいリフレッシュトークンは出ません（access_type=offline が必要）

長期間使わないと失効する可能性もあるため、定期的に使用するのがベストです

✅ まとめ
項目	内容
ユーザーがOAuthログインしたら、あなたのDriveにアクセスできる？	❌ できません（各ユーザーのDriveにアクセス）
あなたのDriveにある音楽をアプリで提供するには？	✅ あなたのトークンを使ってDrive APIにアクセス
リフレッシュトークンを使う場面	✅ あなたのトークンが期限切れになったとき、自動更新するために使う
ーーーーーーーー


<7/6の実施計画>
・各画面の機能確認・修正
　（１）ログイン画面
　　・
　（２）音楽ファイル一覧表示画面
　　・ログイン中名の修正→ログインでニックネームの追加（7/6）
　　・記録一覧のボタンを上に
　　・長時間後は、ログアウトor　画面そのままに　（要フォローPCスリープ時は？）
　　　＊ログイン時にGoogle認証が常に求められるようになった
　（３）音楽再生画面
　　・ボタンの位置統一（済）
　　　改：メモ内容について、本から反映
　（４）記録一覧画面
　　・カレンダーを見やすく（済）
　　改：カレンダーの日押したら、詳細情報に飛ぶ
　　・記録一覧は、個別記録画面に（済）
　　・明示内容の整合性確認　⇒　実際の瞑想で使用して確認、7/5には携帯でも
　（５）個別記録画面

・各画面のデザイン修正内容の整理
　（１）ログイン画面
　　・瞑想をイメージできる、楽しくなる絵を入れる
　　・大きさ、位置を使いやすく
　（２）音楽ファイル一覧表示画面
　（３）音楽再生画面
　（４）記録一覧画面
　（５）個別記録画面

<7/6の実施結果>　本日の修正内容要約（10項目）
1. ログアウト機能のエラー修正
Deviseのconfig.sign_out_via設定を[:delete, :get]に変更
GETメソッドでのログアウトも許可してルーティングエラーを解決
2. アプリ仕様の正しい理解と方針転換
当初の誤解：各ユーザーが個別にGoogle Drive接続
正しい仕様：管理者のGoogle Driveを事前接続し、一般ユーザーはDeviseログインのみでアクセス
3. MusicControllerの認証ロジック修正
session[:google_access_token]から管理者の固定トークン使用に変更
admin_access_tokenとadmin_refresh_tokenメソッドを追加
環境変数ADMIN_GOOGLE_ACCESS_TOKENとADMIN_GOOGLE_REFRESH_TOKENを参照
4. 音楽ライブラリビューの簡素化
Google Drive接続ボタンを削除
Deviseユーザーのみの認証分岐に修正
サンプル音楽ファイル関連の表示を削除
5. 音楽再生ページの改善
管理者トークンを使用する仕様に合わせて修正
Google認証関連のJavaScriptコードを削除
シンプルな音楽再生・瞑想記録画面に変更
6. 不要なサンプル音楽機能の削除
play_sampleアクションとルートを削除
app/views/music/play_sample.html.erbファイルを削除
get_sample_music_filesメソッドを削除
7. 管理者認証用Rakeタスクの作成
lib/tasks/admin_google_auth.rakeを新規作成
管理者のGoogle Driveトークン取得を自動化
デスクトップアプリケーション用OAuthクライアントID対応
8. OAuth設定の問題解決
ウェブアプリケーション用とデスクトップアプリケーション用の違いを解決
redirect_uri_mismatchエラーの対処
新しいデスクトップアプリケーション用OAuthクライアントID作成をサポート
9. 環境変数の整理と追加
ADMIN_GOOGLE_CLIENT_IDとADMIN_GOOGLE_CLIENT_SECRETを追加
ADMIN_GOOGLE_ACCESS_TOKENとADMIN_GOOGLE_REFRESH_TOKENを追加
管理者用と一般ユーザー用の認証情報を分離
10. システム全体の動作確認と完了
管理者のGoogle Driveトークン取得成功
一般ユーザーがDeviseログインのみで音楽ファイルにアクセス可能
個別のGoogle Drive接続が不要な正しい仕様での動作確認完了
結果：管理者が事前にGoogle Drive接続を行い、一般ユーザーはDeviseログインだけで音楽ライブラリにアクセスできるシステムが完成しました。

＜Google cloud リフレッシュトークン　デバッグ削除内容＞　7/6実施

デバッグ機能の削除（オプション）
本番運用時には、以下のデバッグ機能を削除することをお勧めします：
2分後のテスト用タイマー
「トークンリフレッシュテスト」ボタン
「セッション状態確認」ボタン
詳細なコンソールログ

＊25.7.5 Claude-4-sonnetに切替
→　この時点からすれ違っていた気がする。
＝重要＝　毎回アプリの目的を確認して説明する必要あり
　



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

4. **Renderへのデプロイ** 🔄 7/5実施予定　
   - Renderの無料プランを利用し、アプリをクラウド公開
   - PostgreSQLクラウドDBの設定
   - 本番用Google OAuthリダイレクトURIの追加

5. **追加機能の実装** 🔄 7/6 今後の拡張予定
   - カリキュラム振り返り、メモ帳、ご褒美機能など
   - UI/UXの改善、スマホ対応

6. セキュリティ対策

---

## 備考
- 本番運用ではPostgreSQLを使用
- Google Drive APIの利用にはGoogle Cloud Platformでの設定が必要
- Renderの無料プランはスリープ制限あり
- 環境変数は必ず設定してからアプリを起動すること

---

ご不明点や追加要望があれば、READMEを随時更新してください。 



＜当日初回の依頼文＞
今回アプリの目的と背景

今日は、各画面のボタン機能の繋がり確認から進めますので、よろしくお願いします。

 一連のファイルは下記フォルダにありますので、
コードの修正の対応をお願いします。
`\\wsl.localhost\Ubuntu\home\ytpacky/projects/contest/meditation_app` 

railsへのUbuntuターミナルへの処理は、私の方で行います。


