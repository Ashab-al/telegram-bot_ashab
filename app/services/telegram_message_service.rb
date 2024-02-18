class TelegramMessageService
  def initialize
    @bot = Telegram.bot
  end

  def sending_vacancy_to_users(data)
    begin
      text_formation = "Категория: #{data.category_title}\n\n" \
                      "#{data.description}"

      Category.find_by(name: data.category_title).user.each do |user|
        @user = user
        if @user.bot_status == "works"
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
    rescue => e
      text_err = "TelegramMessageService sending_vacancy_to_users err: #{e}\n" \
                 "Имя пользователя: #{@user.name}\n" \
                 "platform_id: #{@user.platform_id}\n"
      @bot.send_message(chat_id: 377884669, text: text_err)
    end
  end

  def send_payment_notification(data)
    @bot.send_message(chat_id: 377884669, text: data.to_s)
  end
end