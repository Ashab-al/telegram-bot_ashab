class Tg::Button::ForVacancyInteractor  < ActiveInteraction::Base
  object :user, presence: true
  symbol :outcome, presence: true
  integer :message_id, presence: true
  integer :vacancy_id, presence: true
  
  def execute
    if [:blacklist, :out_of_points].include?(outcome)
      {status: :warning}
    elsif outcome == :open_vacancy
      {status: :open, button: create_button}
    end
  end

  def create_button
    {
      inline_keyboard: [
        [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points', smile: user.point <= 5 ? I18n.t('smile.low_battery') : I18n.t('smile.full_battery'))}", 
          callback_data: "#{I18n.t('buttons.points')}" }],
        [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", 
          callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: message_id, vacancy_id: vacancy_id ) }]
      ]
    }
  end
end