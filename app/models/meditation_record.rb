class MeditationRecord < ApplicationRecord
  belongs_to :user

  # simple_calendar用
  def start_time
    self.date
  end
end
