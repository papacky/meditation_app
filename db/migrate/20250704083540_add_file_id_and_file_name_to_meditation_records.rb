class AddFileIdAndFileNameToMeditationRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :meditation_records, :file_id, :string
    add_column :meditation_records, :file_name, :string
  end
end

#Github反映漏れ