class AuthController < ApplicationController
  def google_oauth2
    # OmniAuthが認証情報をsessionに保存
    if request.env['omniauth.auth']
      session[:google_access_token] = request.env['omniauth.auth']['credentials']['token']
      session[:google_refresh_token] = request.env['omniauth.auth']['credentials']['refresh_token']
      session[:user_email] = request.env['omniauth.auth']['info']['email']
      session[:user_name] = request.env['omniauth.auth']['info']['name']
      
      redirect_to music_path, notice: 'Google Driveに接続しました！'
    else
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
        session[:google_access_token] = google_drive_service.access_token
        render json: { success: true }
      else
        render json: { success: false }, status: :unauthorized
      end
    else
      render json: { success: false }, status: :unauthorized
    end
  end
end 