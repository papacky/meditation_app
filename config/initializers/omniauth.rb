require 'omniauth'
require 'omniauth-google-oauth2'

OmniAuth.config.allowed_request_methods = [:post, :get]

Rails.application.config.middleware.insert_after ActionDispatch::Session::CookieStore, OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
end 