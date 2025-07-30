class MeditationRecord < ApplicationRecord
  belongs_to :user

  # 属性アクセスを追加
  attr_accessor :file_name, :file_id

  # バリデーション
  validates :date, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :user, presence: true

  # simple_calendar用
  def start_time
    self.date
  end
end
