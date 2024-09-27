# Authentication

[https://dev.to/kevinluo201/building-a-simple-authentication-in-rails-7-from-scratch-2dhb](https://dev.to/kevinluo201/building-a-simple-authentication-in-rails-7-from-scratch-2dhb)

## 1. Build a model with a password
First, we need a method with which to hash the password. Add BCrypt to the <code>Gemfile</code>:

```ruby
    gem "bcrypt"
```

Then run <code>bundle</code>.

Now we need a model. Run:

```bash
    rails generate model user email password password_confirmation
```

Make use of BCrypt via the user model at <code>user.rb</code>:

```ruby
  class User < ApplicationRecord
    has_secure_password
    validates :name, presence: true, uniqueness: true
  end
```

Also add validations for email, and so on.

At this point, run <code>rails db:migrate</code>.

## 2. Controllers to deal with user creation
Now, a matching controller, but only with index (to show users), new (to build the form), and create (to POST to):

```bash
rails generate controller users index new create 
```

Now link up the routes inside <code>routes.rb</code>.

```ruby 
resources :user, only: [:index, :new, :create]
```

Open up <code>users_controller.rb</code> and add the relevant instance methods:

```ruby
  class UsersController < Application Controller
    def index
        @users = User.all
    end 

    def new 
        @user = User.new
    end 

    def create 
        @user = User.new(user_params)
```

Note the use of <code>user_params</code>, which is an instance method of the UsersController class. We will add this as a private instance method. First, however, still inside <code>users_controller.rb</code>, add the finishing touches to the create method:

```ruby
        if @user.save
        flash[:notice] = "User created."
        else 
        flash[:alert] = "User not created."
        render :new, status: :unprocessable_entity
        end
    end
  end
```

<code>@user.save</code> returns true if the user was successfully created from the POST from /new to /users; <code>flash notice</code> is success. Conversely, if it failed, <code>flash alert</code> indicates failure and tehn redirects back to the form to create a user at new, using <code>:unprocessable_entity</code>

Finally, we add the private method that dictates strong params, which builds up a nested has — <code>:user</code> — which contains within it the values we will access later: the User model's attributes.

```ruby
    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
```

Note that while the actual terms in the database schema is password_digest, it is referred to here as password.

Onto the views.

## 3. Views for user signup.

Build out the forms to create users, displaying errors, at <code>new.html.erb</code>:

```erb
<div class="messages">
<%= form_with model: @user do |f| %>
  <% if @user.errors.any? %>
      <div>
          <ul>
              <% @user.errors.full_messages.each do |message| %>
                  <li><%= message %></li>
              <% end %>
          </ul>
      </div>
<% end %>
</div>
```

Then, the actual form itself:

```erb
  <div id="signup">
      <div>
          <%= f.label :name %>
          <%= f.text_field :name %><br />
      </div>
      <div>
          <%= f.label :password %>
          <%= f.password_field :password %><br />
      </div>
      <div>
          <%= f.label :password_confirmation %>
          <%= f.password_field :password_confirmation %><br />
      </div>
      <p class="centre">
          <%= f.submit %>
      </p>
  <% end %>

  </div>
```

This submits a POST from new to create, and the user is created successfully if the passwords match.

Next, head to <code>application.html.erb</code> and add a flash message above the main <code>yield</code> for partials:

```erb
      <% flash.each do |type, message| %>
      <div>
        <% message %>
      </div>
    <% end %>
```

You now have a working user model, controller, and views, which all you to view users, create users with a secure password — and confirmation — and you can now access them.

Open Sqlite3 and pull out the database via:

```SQL
  SELECT id, name, password_digest FROM users;
```

Next, you need to add sessions.

# Sessions

First, start by generating a controller for sessions, in this case called <code>user_sessions</code>:

```bash
  rails generate controller user_sessions new create 
```

This only has two actions: a GET to the login page, and a POST to check whether the password_digest input here matches the one stored in the database. Open up the controller and add:

```ruby 
class UserSessionsController < ApplicationController

  def new 
    # Interestingly, this starts off with no pre-loaded data. 
    # It does, however, allow for the form to be generated based on the model.
    @user = User.new 
  end 

  def create 
    # This is populated by the information filled out in the login page
    # and then @user.authenticate (supplied by has_secure_password)
    # will return true if the details match.
    @user = User.find_by(name: params[:user][:name])

    # If user exists and the credentials are right, create a session containing the user's ID.
    # Remember: authenticate and find_by both access via params, which is a nested hash. 
    # params = { user => { :name => "value", :password => "value" } }
    # so you have to user params[:user][:password].
    if @user && @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id # Use this in the current_user method in a moment
      redirect_to root_path
    else 
      flash[:alert] = "Login failed"
      redirect_to new_user_session_path # Back to login page
    end
  end
end
```

Now that the logic is in place, the view for the login page needs to be created. We have the apparatus to build the form around the user model because of the controller, so it's a simple form.

[...]

# Cookies (permanent authentication)

Session[:user_id] implements the session via a cookie; even when you close and re-open the site, it remembers you. The cookie used is also encrypted.

# Logouts 

As the user is now logged in via a cookie, in order for them to logout, we need to delete the cookie. To do this, we need to set <code>session[:user_id]</code> to nil. First, add a method to the controller:

```ruby 
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
```

Then, update <code>routes.rb</code> so that it now knows that it will be getting a DELETE request via the destroy method.

Head to a view, in this case the home page, where you want the logout to be (the best place would be in a nav partial accessible from everywhere), and add:

```ruby 
  <%= link_to "Logout", user_session_path(current_user), data: { turbo_method: :delete } %>
```

Clicking this will delete the cookie. 

It's important to remember that <code>current_user</code> was defined in <code>ApplicationController</code>, which means it is available everywhere.

# Next

You now have a working user model with a login and logout. What you need next is:

- A password_confirmation via email when they signup;

- A remember me function (so that the cookie is only stored if the user requests it, using a different method otherwise);

- A password reset.

