class AuthController < ApplicationController
  def google_oauth2
    # OmniAuthが認証情報をsessionに保存
    if request.env['omniauth.auth']
      auth_info = request.env['omniauth.auth']
      credentials = auth_info['credentials']
      
      # デバッグ用ログ
      Rails.logger.info "OAuth認証成功"
      Rails.logger.info "アクセストークン: #{credentials['token'].present? ? '取得済み' : '未取得'}"
      Rails.logger.info "リフレッシュトークン: #{credentials['refresh_token'].present? ? '取得済み' : '未取得'}"
      Rails.logger.info "有効期限: #{credentials['expires_at']}"
      
      session[:google_access_token] = credentials['token']
      session[:google_refresh_token] = credentials['refresh_token']
      session[:user_email] = auth_info['info']['email']
      session[:user_name] = auth_info['info']['name']
      
      # セッション保存後の確認
      Rails.logger.info "セッション保存後 - リフレッシュトークン: #{session[:google_refresh_token].present? ? '保存済み' : '未保存'}"
      
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

  def debug_session
    render json: {
      access_token_present: session[:google_access_token].present?,
      refresh_token_present: session[:google_refresh_token].present?,
      user_email: session[:user_email],
      user_name: session[:user_name],
      access_token_preview: session[:google_access_token]&.first(20),
      refresh_token_preview: session[:google_refresh_token]&.first(20)
    }
  end

  def refresh_google_token
    Rails.logger.info "トークンリフレッシュ開始"
    Rails.logger.info "セッション状態 - アクセストークン: #{session[:google_access_token].present? ? '存在' : '不存在'}"
    Rails.logger.info "セッション状態 - リフレッシュトークン: #{session[:google_refresh_token].present? ? '存在' : '不存在'}"
    
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
        Rails.logger.info "Access token refreshed and session updated"
        render json: { 
          success: true, 
          message: 'トークンリフレッシュ成功',
          new_token: google_drive_service.access_token[0..20] + '...' # ログ用（一部のみ）
        }
      else
        Rails.logger.error "Failed to refresh access token"
        render json: { 
          success: false, 
          message: 'トークンリフレッシュ失敗。再ログインが必要です。' 
        }, status: :unauthorized
      end
    else
      Rails.logger.error "No refresh token available"
      render json: { 
        success: false, 
        message: 'リフレッシュトークンがありません。再ログインが必要です。' 
      }, status: :unauthorized
    end
  end
end 