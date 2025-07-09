# 瞑想記録のテスト用スクリプト
# このファイルを実行して、記録が正常に作成されるかテストします

# Rails環境を読み込み
require_relative 'config/environment'

puts "=== 瞑想記録テスト開始 ==="

# ユーザーが存在するか確認
user = User.first
if user.nil?
  puts "❌ ユーザーが見つかりません。先にユーザーを作成してください。"
  exit
end

puts "✅ ユーザーが見つかりました: #{user.email}"

# 既存の記録数を確認
existing_count = MeditationRecord.count
puts "📊 既存の記録数: #{existing_count}"

# テスト用の記録を作成
test_record = MeditationRecord.new(
  user: user,
  date: Date.current,
  duration: 10,
  notes: "テスト用の瞑想記録",
  file_name: "test_music.mp3"
)

if test_record.save
  puts "✅ テスト記録が正常に作成されました"
  puts "   - ID: #{test_record.id}"
  puts "   - 日付: #{test_record.date}"
  puts "   - 時間: #{test_record.duration}分"
  puts "   - メモ: #{test_record.notes}"
  puts "   - ファイル名: #{test_record.file_name}"
else
  puts "❌ テスト記録の作成に失敗しました"
  puts "   エラー: #{test_record.errors.full_messages}"
end

# 作成後の記録数を確認
new_count = MeditationRecord.count
puts "📊 作成後の記録数: #{new_count}"

# ユーザーに紐づく記録を確認
user_records = user.meditation_records
puts "👤 ユーザーに紐づく記録数: #{user_records.count}"

puts "=== テスト完了 ===" 