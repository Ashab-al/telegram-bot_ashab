class Tg::Button::ForVacancyInteractor  < ActiveInteraction::Base
  object :bot, class: Telegram::Bot::Client, presence: true
  string :callback_id, presence: true
  object :user, presence: true
  symbol :outcome, presence: true
  integer :message_id, presence: true
  integer :vacancy_id, presence: true
  string :view
  
  def execute
    if [:blacklist, :out_of_points].include?(outcome)
      bot.answer_callback_query(callback_query_id: callback_id, text: view, show_alert: true)
    elsif outcome == :open_vacancy
      bot.edit_message_text(text: view, message_id: message_id, chat_id: user.platform_id, parse_mode: 'HTML',
        reply_markup: {inline_keyboard: create_button})
    end
  end

  def create_button
    [
      [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points', smile: user.point <= 5 ? I18n.t('smile.low_battery') : I18n.t('smile.full_battery'))}", 
         callback_data: "#{I18n.t('buttons.points')}" }],
      [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", 
         callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: message_id, vacancy_id: vacancy_id ) }]
    ]
  end
end