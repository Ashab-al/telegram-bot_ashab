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

set app_dir: "/var/www/%{application}"

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
  remote.run "cd %{app_dir} && docker compose build -t %{app_dir}"
  remote.run "cd %{app_dir} && docker compose build up -d"
  remote.run "cd %{app_dir} && docker compose run web rails db:create"
  remote.run "cd %{app_dir} && docker compose run web rails db:migrate"
  remote.run "cd %{app_dir} && docker compose run web rails assets:precompile"
  remote.run "cd %{app_dir} && docker compose run web rails restart"
end

# task :docker_build do 
  
# end

# task :docker_up do
  
# end

# task :rails_db_create do 
  
# end

# task :rails_db_migrate do 
  
# end


# task :rails_assets_precompile do 
  
# end

# task :restart_web_server do 
  
# end