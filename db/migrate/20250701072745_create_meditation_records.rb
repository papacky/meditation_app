class CreateMeditationRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :meditation_records do |t|
      t.date :date
      t.integer :times
      t.integer :duration

      t.timestamps
    end
  end
end
