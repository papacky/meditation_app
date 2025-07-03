class AddUserToMeditationRecords < ActiveRecord::Migration[7.1]
  def change
    add_reference :meditation_records, :user, null: true, foreign_key: true
  end
end
