class Tg::OpenVacancyInteractor < ActiveInteraction::Base
  object :user, presence: true
  integer :id, presence: true

  REDUCE_BALANCE=1
  ZERO_BALANCE=0

  def execute
    vacancy = Vacancy.find_by(id: id)
    return errors.add(:params, :invalid) unless vacancy

    chech_vacancy(vacancy)
  end

  private

  def chech_vacancy(vacancy)
    return {status: :out_of_points, path_view: "callback_query/out_of_points"} if user.bonus + user.point <= ZERO_BALANCE

    contact_information = vacancy.source == Tg::Constants::SOURCE ? vacancy.platform_id : vacancy.contact_information
    
    return {status: :blacklist, vacancy: vacancy, path_view: "callback_query/add_to_blacklist"} if check_blacklist(contact_information)
    return errors.add(:user_update, :error) unless user.update(user.bonus > ZERO_BALANCE ? {bonus: user.bonus - REDUCE_BALANCE} : {point: user.point - REDUCE_BALANCE}) 
    
    {status: :open_vacancy, vacancy: vacancy, path_view: "callback_query/open_vacancy"}
  end

  def check_blacklist(contact_information)
    blacklist = Blacklist.find_by(:contact_information => contact_information)

    return true if blacklist && blacklist.complaint_counter >= Tg::SpamVacancyInteractor::COMPLAINT_COUNTER

    false
  end
end