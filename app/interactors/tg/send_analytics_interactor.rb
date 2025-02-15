class Tg::SendAnalyticsInteractor < ActiveInteraction::Base
  ANALYTICS_VIEW_PATH="app/views/telegram_webhooks/analytics.html.erb"

  object :user, presence: true

  def execute
    @user = user
    @analytics = {
      users_count: User.count,
      works_users: User.where_bot_status(User::BOT_STATUS_WORKS).count,
      bot_blocked_users:  User.where_bot_status(User::BOT_STATUS_BLOCKED).count
    }
    # Переменные экземпляра используются чтобы они могли использоваться во вью (для отправки сообщения через бота)
    Telegram.bot.send_message(
      chat_id: Rails.application.secrets.errors_chat_id, 
      text: ERB.new(File.read(Rails.root.join ANALYTICS_VIEW_PATH)).result(binding)
    )

    @analytics
  end
end