class TaskController < ApplicationController
  #before_action :authenticate
  before_action :set_todo_list, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = Task.where(user_id: request.headers["X-User-ID"]).offset(params[:offset]).limit(params[:limit])
  end

  def create
    @task = Taks.new(task_params)
    if @task.save
    end
  end

  private
  def authenticate
    unless request.headers["X-User-ID"].present? && User.exists?(id: request.headers["X-User-ID"])
      render json: { error: "unauthorized"}, status: :unauthorized
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def todo_list_params
    params.require(:todo_list).permit(:title, :description)
    ##
    # {"todo_list": { "title": ""}}
  end
end
