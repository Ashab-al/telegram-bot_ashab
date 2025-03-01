class Api::Vacancy::BlackListCheckInteractor < ActiveInteraction::Base
  integer :platform_id, presence: true
  string :contact_information, presence: true
  
  def execute
    blacklist = Blacklist.where([
      "contact_information = '#{platform_id}'",
      "contact_information = '#{contact_information}'"
    ].join(" OR "))
    
    return errors.add(:blacklist, I18n.t("error.messages.error_validate_vacancy")) unless blacklist.empty?

    blacklist
  end
end