class TodoItemsController < ApplicationController
  before_action :authenticate

  def index
    @todo_items = TodoItem.where(params[:user_id])
    @user_id = params[:user_id]
  end

  def create
    todo_item = TodoItem.new(todo_items_params)
    if todo_item.save
      @notice='saved completed'
      redirect_to action: :index, :user_id => params[:user_id]
    else
      @notice='saved error'
      redirect_to action: :index, :user_id => params[:user_id]
    end
  end

  private
  def authenticate
    unless params[:user_id].present? && User.exists?(id: params[:user_id])
      render json: { error: "unauthorized"}, status: :unauthorized
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_todo_items
    @todo_items = TodoItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def todo_items_params
    params.permit(:content, user_id: params[:user_id])
  end
end
