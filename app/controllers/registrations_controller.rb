# Handles account sign-up (creating new User records), as opposed to SessionsController,
# which handles signing in and out of an existing account.
class RegistrationsController < ApplicationController
  # Sign-up must be reachable while logged out, so this controller also opts out of the
  # global login requirement.
  skip_before_action :require_login

  # Stricter throttle specifically on POST /signup, since account creation is cheap to
  # automate: 5 attempts per IP every 15 minutes (on top of the app-wide limit above).
  rate_limit to: 5, within: 15.minutes, only: :create, name: "signup", with: :too_many_signup_attempts

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

  # Handler for the signup rate_limit above.
  def too_many_signup_attempts
    @user = User.new # keep the re-rendered form bound to an (empty) model, like #new does
    flash.now[:alert] = "Too many signup attempts. Please wait a few minutes and try again."
    render :new, status: :too_many_requests
  end
end
