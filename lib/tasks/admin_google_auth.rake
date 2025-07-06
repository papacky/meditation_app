namespace :admin do
  desc "管理者のGoogle Driveトークンを取得"
  task google_auth: :environment do
    require 'google/apis/drive_v3'
    require 'googleauth'
    require 'googleauth/stores/file_token_store'
    
    # 管理者認証用のGoogle OAuth2設定（デスクトップアプリケーション用）
    client_id = ENV['ADMIN_GOOGLE_CLIENT_ID'] || ENV['GOOGLE_CLIENT_ID']
    client_secret = ENV['ADMIN_GOOGLE_CLIENT_SECRET'] || ENV['GOOGLE_CLIENT_SECRET']
    
    unless client_id && client_secret
      puts "エラー: ADMIN_GOOGLE_CLIENT_IDとADMIN_GOOGLE_CLIENT_SECRETを環境変数に設定してください"
      puts "または、GOOGLE_CLIENT_IDとGOOGLE_CLIENT_SECRETを設定してください"
      exit 1
    end
    
    puts "使用するクライアントID: #{client_id[0..20]}..."
    
    # OAuth2クライアントの設定
    client = Google::Auth::UserRefreshCredentials.new(
      client_id: client_id,
      client_secret: client_secret,
      scope: ['https://www.googleapis.com/auth/drive.readonly'],
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    
    # 認証URLを生成
    auth_url = client.authorization_uri.to_s
    puts "以下のURLをブラウザで開いて認証してください:"
    puts auth_url
    puts
    puts "認証後に表示される認証コードを入力してください:"
    auth_code = STDIN.gets.chomp
    
    # 認証コードを使ってトークンを取得
    client.code = auth_code
    client.fetch_access_token!
    
    puts
    puts "=== 管理者のGoogle Driveトークンが取得できました ==="
    puts "以下の環境変数を設定してください:"
    puts
    puts "ADMIN_GOOGLE_ACCESS_TOKEN=#{client.access_token}"
    puts "ADMIN_GOOGLE_REFRESH_TOKEN=#{client.refresh_token}"
    puts
    puts "これらの値を.envファイルまたは本番環境の環境変数に設定してください。"
    puts "リフレッシュトークンは長期間有効ですが、アクセストークンは1時間で期限切れになります。"
    puts "アプリケーションが自動的にリフレッシュトークンを使用してアクセストークンを更新します。"
  end
end 