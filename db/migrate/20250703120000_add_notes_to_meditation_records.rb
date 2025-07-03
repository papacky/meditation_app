class AddNotesToMeditationRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :meditation_records, :notes, :string
  end
end 