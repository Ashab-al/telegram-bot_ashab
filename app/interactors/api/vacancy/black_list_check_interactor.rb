class Api::Vacancy::BlackListCheckInteractor < ActiveInteraction::Base
  string :platform_id
  string :contact_information
  string :source
  
  def execute
    blacklist = source == "tg_chat" ? Blacklist.find_by(:contact_information => platform_id) : Blacklist.find_by(:contact_information => contact_information)
    return errors.add(:vacancy, I18n.t("error.messages.error_validate_vacancy")) if blacklist && blacklist.complaint_counter >= 2

    true
  end
end