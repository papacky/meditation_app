class MusicController < ApplicationController
  before_action :require_google_auth, only: [:index, :play]

  def index
    if session[:google_access_token]
      begin
        service = GoogleDriveService.new(session[:google_access_token])
        @music_files = service.list_music_files
      rescue => e
        @music_files = []
        flash.now[:alert] = "Google Driveからのファイル取得に失敗しました: #{e.message}"
      end
    else
      @music_files = []
    end
  end

  def play
    @file_id = params[:file_id].to_s.strip
    @file_name = params[:file_name]
    
    if session[:google_access_token]
      service = GoogleDriveService.new(session[:google_access_token])
      @file_metadata = service.get_file_metadata(@file_id)
    end
    
    # 瞑想記録を作成
    @meditation_record = MeditationRecord.new(
      date: Date.current,
      duration: 0, # 後でJavaScriptで更新
      notes: "音楽: #{@file_name}"
    )
  end

  # Google Driveから音楽ファイルをストリーミング配信
  def stream
    file_id = params[:file_id].to_s.strip
    access_token = session[:google_access_token]
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
      Rails.logger.info "[DriveAPI] response.code: \\#{response.code}"
      Rails.logger.info "[DriveAPI] response.body: \\#{response.body[0..200]}"
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

  def require_google_auth
    unless session[:google_access_token]
      redirect_to '/auth/google_oauth2'
    end
  end
end 