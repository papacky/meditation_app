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
    @file_id = params[:file_id]
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

  private

  def require_google_auth
    unless session[:google_access_token]
      redirect_to '/auth/google_oauth2'
    end
  end
end 