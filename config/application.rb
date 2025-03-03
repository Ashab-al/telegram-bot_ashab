require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups(
  assets: %i[development test],
  pry: %i[development test]
))
# load pry for production console
Bundler.require(:pry) if defined?(Rails::Console)
Bundler.require(*Rails.groups)
module TelegramBotApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.api_only = true
    config.debug_exception_response_format = :api

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.factory_bot.definition_file_paths = ['spec/factories']

    lib = root.join('lib')

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join('assets'),
      lib.join('tasks'),
      lib.join('generators')
    )
  end
end
