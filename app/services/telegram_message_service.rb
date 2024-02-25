class TelegramMessageService
  def initialize
    @bot = Telegram.bot
  end

  def sending_vacancy_to_users(data)
    text_formation = "Категория: #{data.title}\n\n" \
                    "#{data.description}"
    Category.find_by(name: data.category_title).user.find_each do |user|
      begin
        next unless user.bot_status == "works"
        
        result_send = @bot.send_message(chat_id: user.platform_id, text: text_formation)
        @bot.edit_message_text(text: text_formation,
                            message_id: result_send["result"]["message_id"],
                            chat_id: user.platform_id,
                            reply_markup: {
                              inline_keyboard: [
                              [{ text: "💎 Получить контакты 💎", callback_data: "mid_#{result_send["result"]["message_id"]}_bdid_#{data["id"]}" }],
                              [{ text: "🤖 Спам 🤖", callback_data: "spam_mid_#{result_send["result"]["message_id"]}_bdid_#{data["id"]}" }]
                            ]
                          })
        
      rescue => e
        user.update(bot_status: "bot_blocked")
        text_err = "TelegramMessageService sending_vacancy_to_users err: #{e}\n" \
                  "Имя пользователя: #{user.name}\n" \
                  "platform_id: #{user.platform_id}\n" \
                  "Статус бота поменялся: #{user.bot_status}"
        @bot.send_message(chat_id: 377884669, text: text_err)
        Rails.logger.error(text_err)
      end
    end
  end

  def send_payment_notification(data)
    @bot.send_message(chat_id: 377884669, text: data.to_s)
  end
end