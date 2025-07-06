module ApplicationHelper
  def format_duration(minutes)
    return "0分" if minutes.nil? || minutes == 0
    
    hours = minutes / 60
    remaining_minutes = minutes % 60
    
    if hours > 0 && remaining_minutes > 0
      "#{hours}時間#{remaining_minutes}分"
    elsif hours > 0
      "#{hours}時間"
    else
      "#{remaining_minutes}分"
    end
  end
end
