class ApplicationController < ActionController::Base
  protected

  # Deviseのサインアップ後のリダイレクト先を設定
  def after_sign_up_path_for(resource)
    music_path # 音楽ライブラリページにリダイレクト
  end

  # Deviseのサインイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    music_path # 音楽ライブラリページにリダイレクト
  end
end
