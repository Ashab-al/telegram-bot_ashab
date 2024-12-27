class Tg::OpenVacancyInteractor < ActiveInteraction::Base
  object :user, presence: true
  object :bot, class: Telegram::Bot::Client
  integer :message_id, presence: true
  integer :vacancy_id, presence: true
  string :callback_id

  def execute
    vacancy = Vacancy.find_by(id: vacancy_id)
    
    outcome = chech_vacancy(vacancy)
    
    bot.answer_callback_query(
      callback_query_id: callback_id,
      text: I18n.t('user.balance.out_of_points', bonus: user.bonus, point: user.point),
      show_alert: true
    ) if outcome[:status] == :out_of_points

    bot.answer_callback_query(
      callback_query_id: callback_id,
      text: I18n.t('notice_message.add_to_blacklist'),
      show_alert: true
    ) if outcome[:status] == :blacklist

    bot.edit_message_text(
      text: I18n.t('vacancy.vacancy_plus_contacts', category_title: vacancy.category_title, 
                    points: user.point + user.bonus, description: vacancy.description, 
                    contact_information: vacancy.contact_information
                  ), 
      message_id: message_id,
      chat_id: user.platform_id, parse_mode: 'HTML',
      reply_markup: {inline_keyboard: Tg::Button::ForVacancyInteractor.run(
                                        user: user, 
                                        message_id: message_id, 
                                        vacancy_id: vacancy_id).result}
                                      ) if outcome[:status] == :open_vacancy
  
  end

  private

  def chech_vacancy(vacancy)
    return {status: :out_of_points} if user.bonus + user.point <= 0

    
    contact_information = vacancy.source == "#{I18n.t('vacancy.source')}" ? vacancy.platform_id : vacancy.contact_information
    
    return {status: :blacklist, vacancy: vacancy} if check_blacklist(contact_information)
    
    if user.bonus > 0
      user.update(bonus: user.bonus - 1)
      return {
        status: :open_vacancy, 
        category_title: vacancy.category_title,
        description: vacancy.description,
        contact_information: vacancy.contact_information
      }
    elsif user.point > 0
      user.update(point: user.point - 1)
      return {status: :open_vacancy, vacancy: vacancy}
    end
    {status: :error}
  end

  def check_blacklist(contact_information)
    blacklist = Blacklist.find_by(:contact_information => contact_information)

    return false if blacklist and blacklist.complaint_counter >= 2

    false
  end
end