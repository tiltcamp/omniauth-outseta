# Omniauth::Outseta

This gem enables the use of [Outseta](https://www.outseta.com/) as an authentication provider in combination with the 
[Devise](https://github.com/heartcombo/devise) and [Omniauth](https://github.com/omniauth/omniauth) gems.

## Installation

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
$ rails generate migration AddFieldsToUser email:string outseta_uid:string name:string account_uid:string
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
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Outseta"
        sign_in_and_redirect @user, event: :authentication
      else
        session["devise.outseta_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to new_user_registration_url
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can 
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. Releases are made automatically using
[GitHub Actions and conventional commits](https://andrewm.codes/blog/automating-ruby-gem-releases-with-github-actions/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/omniauth-outseta. This project is
intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the 
[code of conduct](https://github.com/tiltcamp/omniauth-outseta/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Omniauth::Outseta project's codebases, issue trackers, chat rooms and mailing lists is 
expected to follow the [code of conduct](https://github.com/tiltcamp/omniauth-outseta/blob/master/CODE_OF_CONDUCT.md).
