class Tg::SpamVacancyInteractor < ActiveInteraction::Base
  integer :id, presence: true

  def execute
    vacancy = Vacancy.find_by(id: id)
    contact_information = vacancy.source == "tg_chat" ? vacancy.platform_id : vacancy.contact_information
  
    blacklist = Blacklist.find_or_create_by(contact_information: contact_information) do |blacklist|
      blacklist.complaint_counter = 0
    end
    
    return :blacklisted if blacklist.complaint_counter >= 2

    blacklist.increment!(:complaint_counter)
  end
end