# Base class every controller in the app inherits from. Enforces the "logged in by default"
# rule and exposes `current_user`/`logged_in?` to controllers and views.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Runs before every action in every controller unless that controller opts out with
  # `skip_before_action :require_login` (as SessionsController and RegistrationsController do,
  # since sign-in/sign-up must be reachable while logged out).
  before_action :require_login

  # Makes `current_user` and `logged_in?` callable from views (e.g. `_header.html.erb`), not
  # just from controller code.
  helper_method :current_user, :logged_in?

  private

  # Looks up the currently signed-in user from the encrypted session cookie set at login
  # (see SessionsController#create). Memoized with `||=` so repeated calls within one request
  # only hit the database once. Returns nil if no one is signed in.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # True when a user is currently signed in.
  def logged_in?
    current_user.present?
  end

  # Blocks access to the current action and redirects to the sign-in page when no one is
  # signed in. Registered as a `before_action` above so it runs on every protected request.
  def require_login
    if !logged_in?
      redirect_to login_path, alert: "You must be logged in to access this section."
    end
  end
end
