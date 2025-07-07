class MusicController < ApplicationController
  before_action :require_authentication

  def index
    # public/music/配下の音楽ファイル一覧を取得
    music_dir = Rails.root.join('public', 'music')
    @music_files = []
    if Dir.exist?(music_dir)
      @music_files = Dir.entries(music_dir).select { |f| f =~ /\.(mp3|wav|flac|m4a|aac|ogg)$/i }
    end
  end

  def play
    @file_name = params[:file_name]
    # ローカルファイル名をそのまま渡すだけ
  end

  # Google Driveストリーミングは不要になったのでstreamアクションは未使用

  private

  def require_authentication
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end
end 