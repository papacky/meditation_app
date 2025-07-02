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
    session.clear
    redirect_to root_path, notice: 'ログアウトしました。'
  end
end 