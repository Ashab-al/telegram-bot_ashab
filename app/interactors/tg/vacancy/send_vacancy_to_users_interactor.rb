class Tg::Vacancy::SendVacancyToUsersInteractor < ActiveInteraction::Base
  object :vacancy, presence: true

  DELAY = 25.0

  def execute
    users = Category.find_active_users_by_category_name(vacancy.category_title)
    return errors.add(:users, :empty) unless users.present?
    
    users.each do | user |
      begin
        send_message(user, vacancy)
      rescue Telegram::Bot::Forbidden => e
        user.update(bot_status: User::BOT_STATUS_BLOCKED)
      rescue => e
        Telegram.bot.send_message(
          chat_id: Rails.application.secrets.errors_chat_id, 
          text: Tg::Common.erb_render("vacancy", { error: e, user: user })
        )

        Rails.logger.error(Tg::Common.erb_render("vacancy", { error: e, user: user }))
      end
      sleep(users.count / DELAY)
    end

    users.count
  end

  def send_message(user, vacancy)
    hash = { vacancy: vacancy, user: user }
    
    message_id = Telegram.bot.send_message(
      chat_id: user.platform_id, 
      text: Tg::Common.erb_render("vacancy", hash),
      parse_mode: 'HTML'
    )['result']['message_id']
    
    Telegram.bot.edit_message_text(
      text: Tg::Common.erb_render("vacancy", hash), 
      message_id: message_id, 
      chat_id: user.platform_id, 
      parse_mode: 'HTML', 
      reply_markup: {
        inline_keyboard: [
          [{ text: Tg::Common.erb_render("button/get_contact"), callback_data: Tg::OpenVacancyInteractor::OPEN_VACANCY_FOR_BUTTON.call(message_id, vacancy.id) }],
          [{ text: Tg::Common.erb_render("button/by_points", { user: user }), callback_data: "#{I18n.t('buttons.points')}" }],
          [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: message_id, vacancy_id: vacancy.id ) }]
        ]
      }
    )

  end
end