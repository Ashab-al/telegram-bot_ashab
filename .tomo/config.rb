plugin "git"
plugin "env"
plugin "bundler"
plugin "rails"
plugin "nodenv"
plugin "puma"
plugin "rbenv"
plugin "./plugins/telegram-bot_ashab.rb"

host "root@5.35.91.113"

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

set linked_dirs: %w[
  .yarn/cache
  log
  node_modules
  public/assets
  public/packs
  public/vite
  tmp/cache
  tmp/pids
  tmp/sockets
]

setup do
  run "env:setup"
  run "core:setup_directories"
  run "git:config"
  run "git:clone"
  run "git:create_release"
  run "core:symlink_shared"
  run "nodenv:install"
  run "rbenv:install"
  run "bundler:upgrade_bundler"
  run "bundler:config"
  run "bundler:install"
  run "rails:db_create"
  run "rails:db_schema_load"
  # run "rails:db_seed"
  run "puma:setup_systemd"
  run "docker compose build"
  run "docker compose up"
end

deploy do
  run "env:update"
  run "git:create_release"
  run "bundler:install"
  run "rails:db_migrate"
  # run "rails:db_seed"
  run "rails:assets_precompile"
  run "puma:restart"
  run "puma:check_active"
  run "bundler:clean"
  run "docker compose build"
  run "docker compose up"
end
