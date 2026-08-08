# Handles account sign-up (creating new User records), as opposed to SessionsController,
# which handles signing in and out of an existing account.
class RegistrationsController < ApplicationController
  # Sign-up must be reachable while logged out, so this controller also opts out of the
  # global login requirement.
  skip_before_action :require_login

  # GET /signup - renders the sign-up form.
  def new
    @user = User.new
  end

  # POST /signup - creates a new account and immediately signs the user in.
  def create
    @user = User.new(user_params)

    if @user.save
      # Signing up logs the user in right away, no separate login step required.
      session[:user_id] = @user.id
      redirect_to tasks_path, notice: "Account created successfully! Welcome, #{@user.name}."
    else
      # Re-render the sign-up form with validation errors (e.g. duplicate email,
      # mismatched password confirmation).
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Whitelists which submitted user fields may be mass-assigned. `password_confirmation`
  # isn't a database column; `has_secure_password` uses it only to validate that it
  # matches `password` before saving.
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
