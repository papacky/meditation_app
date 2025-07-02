require 'google/apis/drive_v3'
require 'googleauth'

class GoogleDriveService
  def initialize(access_token)
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
end 