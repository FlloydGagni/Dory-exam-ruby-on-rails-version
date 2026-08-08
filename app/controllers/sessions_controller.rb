# Handles signing in and out. This is the one controller (besides RegistrationsController)
# that must remain reachable while logged out.
class SessionsController < ApplicationController
  # Opts out of ApplicationController's global "must be logged in" requirement, since a
  # logged-out visitor needs to reach this controller in order to log in at all.
  skip_before_action :require_login

  # Stricter throttle specifically on POST /login to blunt brute-force password guessing:
  # 10 attempts per IP every 3 minutes (on top of the app-wide limit in ApplicationController).
  rate_limit to: 10, within: 3.minutes, only: :create, name: "login", with: :too_many_login_attempts

  # GET /login - renders the sign-in form. Also the app's root path.
  def new
  end

  # POST /login - authenticates the submitted email/password and starts a session.
  def create
    user = User.find_by(email: params[:email])

    # `&.authenticate` short-circuits to nil (falsy) if no user was found, and otherwise
    # compares the submitted password against the stored bcrypt digest.
    if user&.authenticate(params[:password])
      # Storing the id in the encrypted session cookie is what makes the user "logged in"
      # for every subsequent request (see ApplicationController#current_user).
      session[:user_id] = user.id
      redirect_to tasks_path, notice: "Logged in successfully! Welcome back, #{user.name}."
    else
      # Same message whether the email doesn't exist or the password is wrong, so a bad
      # actor can't use this form to discover which emails are registered.
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout - clears the session, signing the user out.
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "You have been logged out."
  end

  private

  # Handler for the login rate_limit above.
  def too_many_login_attempts
    flash.now[:alert] = "Too many login attempts. Please wait a few minutes and try again."
    render :new, status: :too_many_requests
  end
end
