# Manages the shared, global category list. Unlike TasksController, queries here are not
# scoped to current_user since categories belong to no one in particular.
class CategoriesController < ApplicationController
  # GET /categories - lists every category and provides a blank one for the "add category" form.
  def index
    @categories = Category.order(:name)
    @category = Category.new
  end

  # POST /categories - creates a new shared category.
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: "Category \"#{@category.name}\" created."
    else
      # Re-render the index page (which doubles as the create form) with validation errors,
      # reloading the category list since it isn't part of the submitted params.
      @categories = Category.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  private

  # Whitelists which submitted category fields may be mass-assigned.
  def category_params
    params.require(:category).permit(:name)
  end
end
