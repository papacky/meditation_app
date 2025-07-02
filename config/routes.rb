Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Google OAuth認証
  get '/auth/:provider/callback', to: 'auth#google_oauth2'
  get '/auth/failure', to: 'auth#failure'
  get '/logout', to: 'auth#logout'

  # 音楽ファイル管理
  get '/music', to: 'music#index'
  get '/music/play', to: 'music#play'

  # 瞑想記録管理
  resources :meditation_records
  post '/meditation_records/create_from_music', to: 'meditation_records#create_from_music'

  # Defines the root path route ("/")
  root "music#index"
end
