class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = current_user.tasks.includes(:category)

    if params[:status].present?
      @tasks = @tasks.where(status: params[:status])
    end

    if params[:category_id].present?
      @tasks = @tasks.where(category_id: params[:category_id])
    end

    if params[:search].present?
      @tasks = @tasks.where("title ILIKE ?", "%#{params[:search]}%")
    end

    @tasks = @tasks.order(created_at: :desc)

    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @limit = (params[:limit] || 5).to_i
    @limit = 5 if @limit < 1

    @total_count = @tasks.count
    @total_pages = (@total_count / @limit.to_f).ceil
    @total_pages = 1 if @total_pages < 1

    @tasks = @tasks.offset((@page - 1) * @limit).limit(@limit)

    @categories = Category.order(:name)
  end

  def new
    @task = current_user.tasks.build
    @categories = Category.order(:name)
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: "Task \"#{@task.title}\" created."
    else
      @categories = Category.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    @categories = Category.order(:name)
  end

  def update
    @categories = Category.order(:name)

    if @task.update(task_params)
      redirect_to task_path(@task), notice: "Task \"#{@task.title}\" updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Task \"#{@task.title}\" deleted."
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :due_date, :category_id)
  end
end
