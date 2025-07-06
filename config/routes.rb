Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Google OAuth認証
  get '/auth/:provider/callback', to: 'auth#google_oauth2'
  get '/auth/failure', to: 'auth#failure'
  get '/logout', to: 'auth#logout'
  get '/logout_complete', to: 'auth#logout_complete', as: 'logout_complete'
  post 'refresh_google_token', to: 'auth#refresh_google_token'
  get 'debug_session', to: 'auth#debug_session'

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
