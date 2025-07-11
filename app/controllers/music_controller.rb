class MusicController < ApplicationController
  before_action :require_authentication

  def index
    # public/music/配下の音楽ファイル一覧を取得
    music_dir = Rails.root.join('public', 'music')
    @music_files = []
    durations = {
      '01' => '1分', '02' => '21分', '03' => '57分', '04' => '43分', '05' => '47分',
      '06' => '46分', '07' => '17分', '08' => '6分', '09' => '8分', '10' => '23分',
      '11' => '45分', '12' => '37分', '13' => '30分', '14' => '9分'
    }
    if Dir.exist?(music_dir)
      files = Dir.entries(music_dir).select { |f| f =~ /\.(mp3|wav|flac|m4a|aac|ogg)$/i }
      files = files.sort_by { |name| name[/\A(\d{2})_/, 1].to_i }
      @music_files = files.map do |name|
        num = name[/\A(\d{2})_/, 1]
        { name: name, duration: durations[num] || '' }
      end
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