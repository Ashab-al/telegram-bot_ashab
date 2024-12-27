class Tg::SpamVacancyInteractor < ActiveInteraction::Base
  object :bot, class: Telegram::Bot::Client
  integer :vacancy_id, presence: true

  def execute
    vacancy = Vacancy.find_by(id: vacancy_id)
    contact_information = vacancy.source == "tg_chat" ? vacancy.platform_id : vacancy.contact_information
  
    blacklist = Blacklist.find_or_create_by(contact_information: contact_information) do |blacklist|
      blacklist.complaint_counter = 0
    end
  
    if blacklist.complaint_counter >= 2
      bot.answer_callback_query "Эта вакансия была определена как нежелательная и добавлена в наш черный список. 🚫😕", show_alert: true
    else
      bot.answer_callback_query "Ваша жалоба на данную вакансию успешно отправлена. 🚀✅", show_alert: true
      
      blacklist.increment!(:complaint_counter)
    end
  end

end