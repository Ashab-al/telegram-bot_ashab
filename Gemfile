source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.2", ">= 7.0.2.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

gem "pg", "~> 1.5.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
 
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

gem "telegram-bot", "~> 0.15.5"

# My gems
gem 'rest-client'
gem 'yookassa'
gem 'webpacker'
gem "tailwindcss-rails", "~> 2.1"
gem 'tomo'
gem 'sidekiq'
# end

group :pry do
  gem "awesome_print"
  gem "pry"
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "spring"
  gem "spring-commands-rspec"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  # gem "capybara"
  # gem "selenium-webdriver"
  # gem "webdrivers"
  gem 'factory_bot_rails'
  gem "rspec-rails"
  gem "rspec-its"
end


