Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # ヘルスチェック用のルート（シンプルな応答）
  get '/health', to: proc { [200, {}, ['OK']] }


  # 音楽ファイル管理
  get '/music', to: 'music#index'
  get '/music/play', to: 'music#play'
  get '/music/stream/:file_id', to: 'music#stream', as: 'music_stream'

  # 瞑想記録管理
  resources :meditation_records do
    collection do
      get :list
    end
  end
  post '/meditation_records/create_from_music', to: 'meditation_records#create_from_music'

  # Defines the root path route ("/")
  root "music#index"
end
