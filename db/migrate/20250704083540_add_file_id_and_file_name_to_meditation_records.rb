class AddFileIdAndFileNameToMeditationRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :meditation_records, :file_id, :string
    # file_nameカラムは既に存在するため削除
    # add_column :meditation_records, :file_name, :string
  end
end

#Github反映漏れ