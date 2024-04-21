class TelegramMessageService
  include SendVacancyService

  def initialize
    @bot = Telegram.bot
  end

  def sending_vacancy_to_users(data_vacancy)
    Category.find_by(name: data_vacancy.category_title).user.find_each do |user|
      begin
        next unless user.bot_status == "works"
        text = "<b>Категория:</b> #{data_vacancy.title}\n" \
                    "<b>Всего поинтов на счету:</b> #{user.point + user.bonus}\n\n" \
                    "#{data_vacancy.description}"   
        send_vacancy(
            @bot, 
            user, 
            text ,
            data_vacancy
          )
        
      rescue Telegram::Bot::Forbidden => e
        user.update(bot_status: "bot_blocked")
        text_err = "TelegramMessageService sending_vacancy_to_users err (rescue Telegram::Bot::Forbidden): #{e}\n" \
                  "Имя пользователя: #{user.name}\n" \
                  "platform_id: #{user.platform_id}\n" \
                  "Статус бота поменялся: #{user.bot_status}"
        @bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: text_err)
        Rails.logger.error(text_err)

      rescue => e
        text_err = "TelegramMessageService sending_vacancy_to_users err: #{e}\n" \
                  "Имя пользователя: #{user.name}\n" \
                  "platform_id: #{user.platform_id}\n" \
                  "Статус бота: #{user.bot_status}"
        @bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: text_err)
        Rails.logger.error(text_err)
      end
    end
  end

  def send_payment_notification(data_vacancy)
    @bot.send_message(chat_id: 377884669, text: data_vacancy.to_s)
  end
end