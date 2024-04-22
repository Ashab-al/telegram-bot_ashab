module SendVacancyService
  def send_vacancy(bot, user, text, data_vacancy)
    result_send = bot.send_message(chat_id: user.platform_id, 
                                        text: text, 
                                        parse_mode: 'HTML')
    sleep(0.1)
    bot.edit_message_text(text: text,
                        message_id: result_send["result"]["message_id"],
                        chat_id: user.platform_id,
                        parse_mode: 'HTML',
                        reply_markup: {
                          inline_keyboard: [
                          [{ text: "Получить контакт 💎", callback_data: "mid_#{result_send["result"]["message_id"]}_bdid_#{data_vacancy.id}" }],
                          [{ text: "Купить поинты #{user.point <= 5 ? "🪫" : "🔋"}", callback_data: "Поинты" }],
                          [{ text: "Спам 🤖", callback_data: "spam_mid_#{result_send["result"]["message_id"]}_bdid_#{data_vacancy.id}" }]
                        ]
                      })
  end
end