class AddFileNameToMeditationRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :meditation_records, :file_name, :string
  end
end 