class Api::User::MailAllInteractor < ActiveInteraction::Base
  string :text, presence: true

  def execute
    bot = Telegram.bot
    User.all.each do |user|
      next if user.bot_status == 'bot_blocked'

      bot.send_message(chat_id: user.platform_id, text: text, parse_mode: 'HTML')
      sleep(0.1)
    rescue Telegram::Bot::Forbidden => e
      user.update(bot_status: 'bot_blocked')
      text_err = "Api::User::MailAllInteractor: #{e}\n" \
                "Имя пользователя: #{user.name}\n" \
                "platform_id: #{user.platform_id}\n" \
                "Статус бота поменялся: #{user.bot_status}"

      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: text_err)
      Rails.logger.error(text_err)
    rescue StandardError => e
      text_err = "Api::User::MailAllInteractor: #{e}\n" \
                "Имя пользователя: #{user.name}\n" \
                "platform_id: #{user.platform_id}\n" \
                "Статус бота: #{user.bot_status}"

      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: text_err)
      Rails.logger.error(text_err)
    end

    true
  end
end
