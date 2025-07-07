class AuthController < ApplicationController
  def google_oauth2
    # OmniAuthが認証情報をsessionに保存
    if request.env['omniauth.auth']
      auth_info = request.env['omniauth.auth']
      credentials = auth_info['credentials']
      
      session[:google_access_token] = credentials['token']
      session[:google_refresh_token] = credentials['refresh_token']
      session[:user_email] = auth_info['info']['email']
      session[:user_name] = auth_info['info']['name']
      
      redirect_to music_path, notice: 'Google Driveに接続しました！'
    else
      Rails.logger.error "OAuth認証失敗: omniauth.authが存在しません"
      redirect_to root_path, alert: '認証に失敗しました。'
    end
  end

  def failure
    redirect_to root_path, alert: '認証に失敗しました。'
  end

  def logout
    reset_session
    redirect_to new_user_session_path, notice: 'ログアウトしました。'
  end

  def logout_complete
  end

  def refresh_google_token
    if session[:google_refresh_token].present?
      google_drive_service = GoogleDriveService.new(
        session[:google_access_token],
        session[:google_refresh_token],
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET']
      )
      if google_drive_service.refresh_access_token
        # セッションの新しいアクセストークンを更新
        session[:google_access_token] = google_drive_service.access_token
        render json: { 
          success: true, 
          message: 'トークンリフレッシュ成功'
        }
      else
        render json: { 
          success: false, 
          message: 'トークンリフレッシュ失敗。再ログインが必要です。' 
        }, status: :unauthorized
      end
    else
      render json: { 
        success: false, 
        message: 'リフレッシュトークンがありません。再ログインが必要です。' 
      }, status: :unauthorized
    end
  end

  def admin_auth_initiate
    client_id = ENV['ADMIN_GOOGLE_CLIENT_ID']
    redirect_uri = "#{request.base_url}/admin_auth/google_oauth2/callback"
    scope = 'https://www.googleapis.com/auth/drive.readonly' # Google Driveの読み取り権限
    auth_url = "https://accounts.google.com/o/oauth2/auth?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{scope}&access_type=offline&prompt=consent"
    redirect_to auth_url, allow_other_host: true
  end

  def admin_google_oauth2_callback
    client_id = ENV['ADMIN_GOOGLE_CLIENT_ID']
    client_secret = ENV['ADMIN_GOOGLE_CLIENT_SECRET']
    redirect_uri = "#{request.base_url}/admin_auth/google_oauth2/callback"
    code = params[:code]

    if code.present?
      # コードをトークンに交換
      token_url = 'https://oauth2.googleapis.com/token'
      uri = URI(token_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = URI.encode_www_form({
        'client_id' => client_id,
        'client_secret' => client_secret,
        'code' => code,
        'redirect_uri' => redirect_uri,
        'grant_type' => 'authorization_code'
      })

      response = http.request(request)
      token_data = JSON.parse(response.body)

      if response.code == '200'
        access_token = token_data['access_token']
        refresh_token = token_data['refresh_token']

        # ログとフラッシュメッセージでトークンを表示（ユーザーがコピーできるように）
        Rails.logger.info "Admin Google Access Token: #{access_token}"
        Rails.logger.info "Admin Google Refresh Token: #{refresh_token}"
        flash[:notice] = "新しいADMIN_GOOGLE_ACCESS_TOKENとADMIN_GOOGLE_REFRESH_TOKENを取得しました。ログを確認し、.envファイルに設定してください。"
        flash[:access_token] = access_token # ビューで表示するために保持
        flash[:refresh_token] = refresh_token # ビューで表示するために保持
        redirect_to root_path
      else
        Rails.logger.error "Failed to exchange code for tokens. Response Code: #{response.code}, Body: #{response.body}"
        flash[:alert] = "管理者トークンの取得に失敗しました: #{token_data['error_description'] || token_data['error']}"
        redirect_to root_path
      end
    else
      Rails.logger.error "Admin OAuth callback failed: code not present. Error: #{params[:error]}, Description: #{params[:error_description]}"
      flash[:alert] = "管理者認証に失敗しました。"
      redirect_to root_path
    end
  end
end 