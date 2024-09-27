class UserSessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_by(name: params[:user][:name])          # Grab user by their ID.

    # Authenticate is a method from has_secure_password on the user model.
    if @user && @user.authenticate(params[:user][:password])  # If user can be found and password matches...
      session[:user_id] = @user.id                            # Create session with the user's ID.
      redirect_to root_path
    else 
      flash[:alert] = "Login failed."
      redirect_to new_user_session_path
    end
  end

  def destroy
    session[:user_id] = nil 
    redirect_to root_path
  end
end
