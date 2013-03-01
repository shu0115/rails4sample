require 'reloader/sse'

class TasksController < ApplicationController
  include ActionController::Live
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.order( created_at: :desc ).all
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render action: 'show', status: :created, location: @task }
      else
        format.html { render action: 'new' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end

  #----------#
  # realtime #
  #----------#
  def realtime
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)

    begin
      tasks = Task.all
      Task.create( title: "タスク#{tasks.length}", content: "コンテント#{tasks.length}" ) if tasks.length <= 9000

      puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}" + " - #{tasks.length} ]"
      sse.write( "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}" + " - #{tasks.length}", event: 'refresh' )

      # 接続終了送信
#      sse.write("stream_end")
    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      sse.close
    end
  end

  #---------------#
  # realtime_show #
  #---------------#
  def realtime_show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :content, :deadline, :count)
    end
end
