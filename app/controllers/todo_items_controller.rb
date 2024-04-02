class TodoItemsController < ApplicationController
  before_action :authenticate
  before_action :set_todo_items, only: [:destroy]

  def index
    @todo_items = TodoItem.where(params[:user_id])
    @user_id = params[:user_id]
  end

  def create
    todo_item = TodoItem.new(todo_items_params)
    if todo_item.save
      flash[:success] = '保存成功'
      redirect_to action: :index, :user_id => @user.id
    else
      flash[:error] = '保存失敗'
      redirect_to action: :index, :user_id => @user.id
    end
  end

  def destroy
    unless @todo_item[:user_id] == @user.id
      flash[:error] = '指定したTODOIDがおかしいよ'
      redirect_to action: :index, :user_id => @user.id
      return
    end
    if @todo_item.destroy
      flash[:success] = '削除成功'
      redirect_to action: :index, :user_id => @user.id
    else
      flash[:error] = '削除失敗'
      redirect_to action: :index, :user_id =>  @user.id
    end
  end

  private
  def authenticate
    unless params[:user_id].present? && User.exists?(id: params[:user_id])
      render json: { error: "unauthorized"}, status: :unauthorized
    end
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_todo_items
    @todo_item = TodoItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def todo_items_params
    {
      "content": params[:content],
      "user_id": @user.id
    }
  end
end
