class MeditationRecord < ApplicationRecord
  belongs_to :user

  # バリデーション
  validates :date, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :user, presence: true

  # simple_calendar用
  def start_time
    self.date
  end
end
