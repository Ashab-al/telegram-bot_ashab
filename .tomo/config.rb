plugin "git"
plugin "env"
plugin "bundler"
plugin "rails"
plugin "nodenv"
plugin "puma"
plugin "rbenv"
plugin "./plugins/telegram-bot_ashab.rb"

set application: "telegram-bot_ashab"
set deploy_to: "/var/www/%{application}"
set rbenv_ruby_version: "3.0.0"
set nodenv_node_version: "21.5.0"
set nodenv_install_yarn: true
set git_url: "git@github.com:Ashab-al/telegram-bot_ashab.git"
set git_branch: "main"
set git_exclusions: %w[
  .tomo/
  spec/
  test/
]

set env_vars: {
  RACK_ENV: "production",
  RAILS_ENV: "production",
  RAILS_LOG_TO_STDOUT: "1",
  RAILS_SERVE_STATIC_FILES: "1",
  RUBY_YJIT_ENABLE: "1",
  BOOTSNAP_CACHE_DIR: "tmp/bootsnap-cache",
  DATABASE_URL: :prompt,
  SECRET_KEY_BASE: :prompt
}


set :app_dir, "/var/www/#{fetch(:application)}"

host "root@5.35.91.113"

setup do
  run "git:clone"
  run "git:create_release"
  run "bundler:install"
  run "rails:db_schema_load"
end

deploy do 
  run "git:config"
  run "git:clone"
  run "git:create_release"
  remote.run "cd #{fetch(:app_dir)} && docker-compose build"
  remote.run "cd #{fetch(:app_dir)} && docker-compose up -d"
  remote.run "cd #{fetch(:app_dir)} && docker-compose run web rails db:create"
  remote.run "cd #{fetch(:app_dir)} && docker-compose run web rails db:migrate"
  remote.run "cd #{fetch(:app_dir)} && docker-compose run web rails assets:precompile"
  remote.run "cd #{fetch(:app_dir)} && docker-compose restart web"
end
