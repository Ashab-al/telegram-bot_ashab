class TelegramMessageService
  def initialize
    @bot = Telegram.bot
  end

  def sending_vacancy_to_users(data)
    text_formation = "Категория: #{data.category_title}\n\n" \
                     "#{data.description}"

    Category.find_by(name: data.category_title).user.each do |user|
      result_send = @bot.send_message(chat_id: user.platform_id, text: text_formation)

      @bot.edit_message_text(text: text_formation,
                          message_id: result_send["result"]["message_id"],
                          chat_id: user.platform_id,
                          reply_markup: {
                            inline_keyboard: [
                            [
                              { text: "Получить контакты",
                                callback_data: "mid_#{result_send["result"]["message_id"]}_bdid_#{data["id"]}" }
                            ]
                          ]
                        }
                          )
    end
    
  end
end