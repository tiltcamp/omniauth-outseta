# Omniauth::Outseta

This gem enables the use of [Outseta](https://www.outseta.com/) as an authentication provider in combination with the 
[Devise](https://github.com/heartcombo/devise) and [OmniAuth](https://github.com/omniauth/omniauth) gems. Outseta
enables you to manage, authenticate, and charge your customers all in one place.

## Installation (With Devise)

### Prerequisites

Ensure you have [Devise](https://github.com/heartcombo/devise) set up for your Ruby on Rails application. If not, you 
can follow the Devise [Getting Started](https://github.com/heartcombo/devise#getting-started) guide.

### Adding the Gem

Add the `omniauth-outseta` gem to your Gemfile:

```ruby
gem 'omniauth-outseta'
```

And then execute:

```bash
$ bundle install
```

### Configuration

To configure the gem, add the following to your Devise initializer (`config/initializers/devise.rb`):

```ruby
config.omniauth :outseta, subdomain: 'your_subdomain', jwt_public_key: <<~PEM
  -----BEGIN CERTIFICATE----- 
  YourPublicKeyHere
  -----END CERTIFICATE-----
PEM
```

Replace `'your_subdomain'` and `'YourPublicKeyHere'` with your actual Outseta subdomain and public key. The public key
can be retrieved by logging in to your Outseta account and navigating to "Auth" -> "Sign up and Login", and expanding
the "Show advanced options" panel inside the "Login settings" section. The last section will be the "JWT Key" card,
containing the public key used to validate the signature on Outseta JWTs.

### User Model

#### Adding Necessary Fields

Add the necessary fields to your User model by generating a migration:

```bash
$ rails generate migration AddFieldsToUser email:string outseta_uid:string:index name:string account_uid:string
```

And add a unique constraint to the `outseta_uid` field in the newly generated migration:

```ruby
add_index :users, :outseta_uid, unique: true
```

And then migrate the database:

```bash
$ rails db:migrate
```

#### Updating the User Model

Update the User model (`app/models/user.rb`) to include the following static `from_outseta_omniauth` method:

```ruby
class User < ApplicationRecord
  devise :trackable, :rememberable, :timeoutable, :omniauthable, omniauth_providers: [:outseta]

  def self.from_outseta_omniauth(auth)
    where(outseta_uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.account_uid = auth.extra.account_uid
    end
  end
end
```

### Omniauth Callbacks Controller

Create or update the Omniauth Callbacks Controller (`app/controllers/users/omniauth_callbacks_controller.rb`) to include
the following:

```ruby
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def outseta
      @user = User.from_outseta_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to user_outseta_omniauth_authorize_url
      end
    end
  end
end
```

### Routes

Ensure your `config/routes.rb` file includes an override for the Omniauth Callbacks Controller. If not, add the following:

```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
end
```

### Without [Database Authenticatable](https://www.rubydoc.info/github/heartcombo/devise/main/Devise/Models/DatabaseAuthenticatable)

This may be obvious to those with a deep familiarity with Devise, but if you opt not to use Devise's 
`database_authenticatable` module (as suggested above) you will not get the default `sessions` routes. This means that 
you will need to create your own 'Sign in' and 'Sign out' pages and routes. You can do this without a new controller by
just overriding the default Devise `sessions/new` view as follows.

First, enable scoped views in your Devise configuration (`config/initializers/devise.rb`):

```ruby
  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  config.scoped_views = true
```

Then, create a new file at `app/views/users/sessions/new.html.erb` with the following contents:

```erb
<%= button_to "Sign in with Outseta", user_outseta_omniauth_authorize_path %>
```

And then add the following `devise_scope :user` block to your `config/routes.rb` file:

```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    authenticated do
      delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
    end

    unauthenticated do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
```

You can then add a sign out button anywhere in your application with the following:

```erb
<%= link_to "Sign out", destroy_user_session_path, data: { "turbo-method": :delete } %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can 
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. Releases are made automatically using
[GitHub Actions and conventional commits](https://andrewm.codes/blog/automating-ruby-gem-releases-with-github-actions/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tiltcamp/omniauth-outseta. This project is
intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
[code of conduct](https://github.com/tiltcamp/omniauth-outseta/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Omniauth::Outseta project's codebases, issue trackers, chat rooms and mailing lists is 
expected to follow the [code of conduct](https://github.com/tiltcamp/omniauth-outseta/blob/master/CODE_OF_CONDUCT.md).
