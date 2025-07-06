class MusicController < ApplicationController
  before_action :require_authentication

  def index
    # 管理者のGoogle Driveトークンを使用して音楽ファイルを取得
    begin
      service = GoogleDriveService.new(
        admin_access_token,
        admin_refresh_token,
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET']
      )
      @music_files = service.list_music_files
    rescue => e
      @music_files = []
      flash.now[:alert] = "音楽ファイルの取得に失敗しました: #{e.message}"
    end
  end

  def play
    @file_id = params[:file_id].to_s.strip
    @file_name = params[:file_name]
    
    # 管理者のGoogle Driveトークンを使用してファイル情報を取得
    begin
      service = GoogleDriveService.new(
        admin_access_token,
        admin_refresh_token,
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET']
      )
      @file_metadata = service.get_file_metadata(@file_id)
    rescue => e
      flash[:alert] = "音楽ファイルの取得に失敗しました: #{e.message}"
      redirect_to music_path and return
    end
    
    # 瞑想記録を作成（ログインユーザーのみ）
    if user_signed_in?
      @meditation_record = MeditationRecord.new(
        date: Date.current,
        duration: 0, # 後でJavaScriptで更新
        notes: "音楽: #{@file_name}",
        user: current_user
      )
    end
  end

  # Google Driveから音楽ファイルをストリーミング配信
  def stream
    file_id = params[:file_id].to_s.strip
    
    # 管理者のGoogle Driveトークンを使用
    access_token = admin_access_token
    unless access_token
      head :unauthorized and return
    end

    require 'net/http'
    require 'uri'

    uri = URI("https://www.googleapis.com/drive/v3/files/#{file_id}?alt=media")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{access_token}"

    http.request(request) do |response|
      Rails.logger.info "[DriveAPI] response.code: #{response.code}"
      if response.code == '200'
        self.response.headers['Content-Type'] = 'audio/mpeg'
        self.response.headers['Content-Disposition'] = 'inline'
        self.response.headers['Cache-Control'] = 'no-cache'
        self.response.headers.delete('Content-Length')
        self.response_body = response.body
      else
        head :not_found
      end
    end
  end

  private

  def require_authentication
    # Deviseユーザーのログインが必要
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end

  # 管理者のGoogle Driveアクセストークンを取得
  def admin_access_token
    # 環境変数から管理者のアクセストークンを取得
    # 実際の運用では、管理者が事前に認証して取得したトークンを設定
    ENV['ADMIN_GOOGLE_ACCESS_TOKEN']
  end

  # 管理者のGoogle Driveリフレッシュトークンを取得
  def admin_refresh_token
    # 環境変数から管理者のリフレッシュトークンを取得
    ENV['ADMIN_GOOGLE_REFRESH_TOKEN']
  end
end 