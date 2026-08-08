class TasksController < ApplicationController
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

  private

  def task_params
    params.require(:task).permit(:title, :description, :status, :due_date, :category_id)
  end
end
