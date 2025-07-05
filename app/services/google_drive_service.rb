require 'google/apis/drive_v3'
require 'googleauth'
require 'net/http'
require 'json'

class GoogleDriveService
  attr_reader :access_token

  def initialize(access_token, refresh_token = nil, client_id = nil, client_secret = nil)
    @access_token = access_token
    @refresh_token = refresh_token
    @client_id = client_id
    @client_secret = client_secret
    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = access_token
  end

  def list_music_files
    # 音楽ファイルの拡張子
    music_extensions = ['mp3', 'wav', 'flac', 'm4a', 'aac', 'ogg']
    query_parts = music_extensions.map { |ext| "fileExtension = '#{ext}'" }
    query = query_parts.join(' or ')
    
    begin
      response = @service.list_files(
        q: query,
        fields: 'files(id,name,mimeType,size,createdTime,modifiedTime,webViewLink)',
        order_by: 'name'
      )
      response.files || []
    rescue => e
      Rails.logger.error "Google Drive API error: #{e.message}"
      []
    end
  end

  def get_file_metadata(file_id)
    begin
      @service.get_file(file_id, fields: 'id,name,mimeType,size,createdTime,modifiedTime,webViewLink')
    rescue => e
      Rails.logger.error "Google Drive API error getting file metadata: #{e.message}"
      nil
    end
  end

  def refresh_access_token
    return false unless @refresh_token && @client_id && @client_secret

    begin
      uri = URI('https://oauth2.googleapis.com/token')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = URI.encode_www_form({
        'client_id' => @client_id,
        'client_secret' => @client_secret,
        'refresh_token' => @refresh_token,
        'grant_type' => 'refresh_token'
      })

      response = http.request(request)
      
      if response.code == '200'
        token_data = JSON.parse(response.body)
        @access_token = token_data['access_token']
        @service.authorization = @access_token
        Rails.logger.info "Google access token refreshed successfully"
        return true
      else
        Rails.logger.error "Failed to refresh Google access token: #{response.body}"
        return false
      end
    rescue => e
      Rails.logger.error "Error refreshing Google access token: #{e.message}"
      return false
    end
  end
end 