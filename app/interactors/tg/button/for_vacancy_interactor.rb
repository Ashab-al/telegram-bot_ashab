class Tg::Button::ForVacancyInteractor  < ActiveInteraction::Base
  object :user, presence: true
  symbol :outcome, presence: true
  integer :message_id, presence: true
  integer :vacancy_id, presence: true
  
  def execute
    if [:blacklist, :out_of_points].include?(outcome)
      {status: :warning}
    elsif outcome == :open_vacancy
      {status: :open, smile: user.point <= 5 ? I18n.t('smile.low_battery') : I18n.t('smile.full_battery')}
    end
  end
end