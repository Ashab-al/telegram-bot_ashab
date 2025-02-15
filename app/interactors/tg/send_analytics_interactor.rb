class Tg::SendAnalyticsInteractor < ActiveInteraction::Base
  ANALYTICS_VIEW_PATH="app/views/telegram_webhooks/analytics.html.erb"

  object :user, presence: true

  def execute
    @user = user
    @analytics = {
      users_count: User.count,
      works_users: Users::FindUserQuery.new({bot_status: User::BOT_STATUS_WORKS}, User).call.count,
      bot_blocked_users: Users::FindUserQuery.new({bot_status: User::BOT_STATUS_BLOCKED}, User).call.count
    }

    Telegram.bot.send_message(
      chat_id: Rails.application.secrets.errors_chat_id, 
      text: ERB.new(File.read(Rails.root.join ANALYTICS_VIEW_PATH)).result(binding)
    )

    @analytics
  end
end