# Handles listing, filtering, searching, and CRUD for the current user's own tasks.
# Every query in this controller starts from `current_user.tasks`, which is what keeps
# one user from ever seeing or modifying another user's tasks.
class TasksController < ApplicationController
  # Loads @task from the current user's own tasks (via `set_task`) before show/edit/update/destroy,
  # so those actions never need to repeat the lookup and can never touch another user's task.
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks - lists the current user's tasks with optional filtering, search, and pagination.
  def index
    # Start from only this user's tasks, eager-loading :category to avoid an extra
    # query per row when the view renders `task.category.name`.
    @tasks = current_user.tasks.includes(:category)

    # Narrow to a single status (pending/in_progress/completed) if requested.
    if params[:status].present?
      @tasks = @tasks.where(status: params[:status])
    end

    # Narrow to a single category if requested.
    if params[:category_id].present?
      @tasks = @tasks.where(category_id: params[:category_id])
    end

    # Case-insensitive, partial-match title search (ILIKE is PostgreSQL-specific).
    if params[:search].present?
      @tasks = @tasks.where("title ILIKE ?", "%#{params[:search]}%")
    end

    # Newest tasks first.
    @tasks = @tasks.order(created_at: :desc)

    # Parse the requested page number, defaulting to and clamping at page 1.
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    # Parse the requested page size, defaulting to and clamping at 5.
    @limit = (params[:limit] || 5).to_i
    @limit = 5 if @limit < 1

    # Count matching rows (post-filter, pre-pagination) so the view can render
    # "Page X of Y" and know whether Next/Previous links should appear.
    @total_count = @tasks.count
    @total_pages = (@total_count / @limit.to_f).ceil
    @total_pages = 1 if @total_pages < 1

    # Apply OFFSET/LIMIT last, after count is taken, to fetch just the current page's rows.
    @tasks = @tasks.offset((@page - 1) * @limit).limit(@limit)

    # Categories are global (not scoped to the user), needed to populate the filter dropdown.
    @categories = Category.order(:name)
  end

  # GET /tasks/new - renders the blank task form.
  def new
    # `current_user.tasks.build` pre-associates the new task with the signed-in user
    # without saving it yet, so `user_id` is set automatically on create.
    @task = current_user.tasks.build
    @categories = Category.order(:name)
  end

  # POST /tasks - creates a task for the current user from submitted form data.
  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: "Task \"#{@task.title}\" created."
    else
      # Re-render the form with validation errors; the category list must be reloaded
      # since it isn't part of the submitted params.
      @categories = Category.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tasks/:id - shows one task. @task is already loaded by the `set_task` before_action.
  def show
  end

  # GET /tasks/:id/edit - renders the edit form for an existing task.
  def edit
    @categories = Category.order(:name)
  end

  # PATCH /tasks/:id - applies form updates to an existing task.
  def update
    @categories = Category.order(:name)

    if @task.update(task_params)
      redirect_to task_path(@task), notice: "Task \"#{@task.title}\" updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/:id - permanently removes a task (the view asks for confirmation first).
  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Task \"#{@task.title}\" deleted."
  end

  private

  # Loads the requested task, but only from the current user's own tasks. Raises
  # ActiveRecord::RecordNotFound (rendered as a 404) if the id belongs to someone else's
  # task or doesn't exist - this is the mechanism that enforces per-user data isolation.
  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  # Whitelists which submitted task fields may be mass-assigned. Notably excludes `user_id`,
  # so a request can never set a task's owner directly.
  def task_params
    params.require(:task).permit(:title, :description, :status, :due_date, :category_id)
  end
end
