class MeditationRecordsController < ApplicationController
  before_action :set_meditation_record, only: [:show, :edit, :update, :destroy]

  def index
    @meditation_records = MeditationRecord.order(date: :desc)
    @total_sessions = @meditation_records.count
    @total_duration = @meditation_records.sum(:duration)
    @total_days = @meditation_records.distinct.count(:date)
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

    if @meditation_record.save
      redirect_to @meditation_record, notice: '瞑想記録が作成されました。'
    else
      render :new, status: :unprocessable_entity
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
    @meditation_record.destroy
    redirect_to meditation_records_url, notice: '瞑想記録が削除されました。'
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
    @meditation_record = MeditationRecord.find(params[:id])
  end

  def meditation_record_params
    params.require(:meditation_record).permit(:date, :duration, :notes)
  end
end 