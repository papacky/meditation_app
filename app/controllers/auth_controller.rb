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
end 