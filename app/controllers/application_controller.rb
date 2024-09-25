class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  def current_user
    # If session is nil, set it to nil, or find the user via the ID stored in the session.
    @current_user ||= session[:user_id]
  end

end
