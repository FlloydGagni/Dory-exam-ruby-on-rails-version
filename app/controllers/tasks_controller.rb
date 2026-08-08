class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = current_user.tasks
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
