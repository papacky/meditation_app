class MeditationRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meditation_record, only: [:show, :edit, :update, :destroy]

  def index
    # カレンダーで表示中の月を取得（パラメータがない場合は今月）
    if params[:start_date].present?
      current_date = Date.parse(params[:start_date])
    else
      current_date = Date.current
    end
    
    start_date = current_date.beginning_of_month
    end_date = current_date.end_of_month

    # 表示中の月の瞑想記録を日付ごとに取得
    @meditation_records = MeditationRecord.where(user: current_user, date: start_date..end_date)

    # 日付ごとの実施回数（カレンダー用）
    @records_by_date = @meditation_records.group(:date).count

    # 表示中の月の集計用
    @total_count = @meditation_records.count
    @active_days = @records_by_date.keys.size
    @total_minutes = @meditation_records.sum(:duration)
    @current_month_name = current_date.strftime("%Y年%-m月")

    # 全期間の累計
    all_records = MeditationRecord.where(user: current_user)
    @total_sessions = all_records.count
    @total_duration = all_records.sum(:duration)
    @total_days = all_records.select(:date).distinct.count
  end

  def list
    # 記録一覧ページ用のアクション
    @meditation_records = MeditationRecord.where(user: current_user)
                                         .order(date: :desc, created_at: :desc)
  end

  def show
  end

  def new
    @meditation_record = MeditationRecord.new
  end

  def edit
  end

  def create
    @meditation_record = MeditationRecord.new(meditation_record_params)
    @meditation_record.user = current_user
    @meditation_record.date ||= Date.current  # dateがnilなら今日をセット

    if @meditation_record.save
      redirect_to list_meditation_records_path, notice: '瞑想記録が作成されました。'
    else
      # エラー時の変数設定を確実に行う
      @file_name = params[:meditation_record][:file_name] if params[:meditation_record] && params[:meditation_record][:file_name]
      @file_id = params[:meditation_record][:file_id] if params[:meditation_record] && params[:meditation_record][:file_id]
      
      # エラーメッセージをログに出力
      Rails.logger.error "Meditation record creation failed: #{@meditation_record.errors.full_messages}"
      
      render 'music/play', status: :unprocessable_entity
    end
  end

  def update
    if @meditation_record.update(meditation_record_params)
      redirect_to @meditation_record, notice: '瞑想記録が更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @meditation_record.user == current_user
      @meditation_record.destroy
      redirect_to list_meditation_records_path, notice: '瞑想記録が削除されました。'
    else
      redirect_to list_meditation_records_path, alert: '削除権限がありません。'
    end
  end

  def create_from_music
    @meditation_record = MeditationRecord.new(
      date: Date.current,
      duration: params[:duration].to_i,
      notes: params[:notes] || "音楽瞑想"
    )

    if @meditation_record.save
      render json: { success: true, record: @meditation_record }
    else
      render json: { success: false, errors: @meditation_record.errors.full_messages }
    end
  end

  private

  def set_meditation_record
    @meditation_record = MeditationRecord.where(user: current_user).find(params[:id])
  end

  def meditation_record_params
    params.require(:meditation_record).permit(:date, :duration, :notes, :file_id, :file_name)
  end
end 