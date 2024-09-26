# Authentication

https://dev.to/kevinluo201/building-a-simple-authentication-in-rails-7-from-scratch-2dhb

Install <code>BCrypt</code> with <code>bundle</code>.

Create model user with <code>name</code>, <code>password</code>, and <code>password_confirmation</code>.

Create users_controller with index, new, and create.

Create routes: resources :user, only: [:index, :new, :create].

Edit the controller: index has @users = User.all; new has @user = User.new; create has @user = User.new(user_params); add if @user.save with notice and flash; add private instance method user_params that has params.require(:user).permit(:name, :password, :password_confirmation).

Create the views using form_for model: @user. Also print the messages via @user.errors.any? and @user.errors.full_messages in a block.

Add flash messages block in application layout.

Query the database via SELECT id, name, password_digest FROM users.

Add tests.

Then build login.