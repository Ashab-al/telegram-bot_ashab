class PaginationService
  include SendVacancyService

  RATE_LIMIT_PER_SECOND = 2
  MINIMUM_INTERVAL = 1.0 / RATE_LIMIT_PER_SECOND

  def initialize(user, vacancy_list, batch_start)
    @bot = Telegram.bot
    @vacancy_list = vacancy_list
    @user = user
    @batch_start = batch_start
  end

  def send_vacancy_pagination(batch_size=3)
    batch = @vacancy_list.to_a.slice(@batch_start, batch_size)
    return @bot.send_message(chat_id: @user.platform_id, text: "Вакансий отправлено #{@vacancy_list.index(batch.last) + 1} из #{@vacancy_list.size}") if batch.nil?

    if batch.any? &&  batch.size >= 1
      batch.each do |vacancy|
        return true if vacancy.nil?
        
        text = "№ #{@vacancy_list.index(vacancy) + 1}\n" \
               "<b>Категория:</b> #{vacancy.title}\n" \
               "<b>Дата отправки:</b> #{vacancy.created_at.strftime('%d.%m.%Y, %H:%M')}\n" \
               "<b>Всего поинтов на счету:</b> #{@user.point + @user.bonus}\n\n" \
               "#{vacancy.description}"  

        send_vacancy(
          @bot, 
          @user, 
          text ,
          vacancy
        )
        sleep(1)
      end
      @bot.send_message(chat_id: @user.platform_id, 
                                        text: "📜 Вакансий отправлено #{@vacancy_list.index(batch.last) + 1} из #{@vacancy_list.size}", 
                                        parse_mode: 'HTML',
                                        reply_markup: {
                          inline_keyboard: [
                          [{ text: "Получить еще 15 ➡️", callback_data: "more_vacancies" }],
                          [{ text: "Купить поинты #{@user.point <= 5 ? "🪫" : "🔋"}", callback_data: "Поинты" }]
                        ]
                      })
      return @vacancy_list.index(batch.last) + 1
    else
      return @bot.send_message(chat_id: @user.platform_id, 
      text: "Вакансий отправлено #{@vacancy_list.index(batch.last) + 1} из #{@vacancy_list.size}")
    end
  end
end
