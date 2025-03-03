class Tg::SendAnalyticsInteractor < ActiveInteraction::Base
  object :user, presence: true

  def execute
    analytics = {
      users_count: User.count,
      works_users: User.active_bot.count,
      bot_blocked_users: User.bot_blocked.count
    }

    Telegram.bot.send_message(
      chat_id: Rails.application.secrets.errors_chat_id,
      text: Tg::Common.erb_render('analytics', { user: user, analytics: analytics })
    )

    analytics
  end
end
