# Authentication

## 1. Build a model with a password
First, we need a method with which to hash the password.

```ruby
gem bcrypt
```

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

After this, you need to add cookies, logouts, and password resets.

# Cookies (permanent authentication)

# Logouts 

# Password resets 

This is a full authentication system which lets users create an account with a secure password, and can be used for all powerful sites.