class Api::Vacancy::BlackListCheckInteractor < ActiveInteraction::Base
  integer :platform_id, presence: true
  string :contact_information, presence: true
  
  def execute
    blacklist = Blacklist.where(contact_information: contact_information).or(Blacklist.where(contact_information: platform_id))

    return errors.add(:blacklist, I18n.t("error.messages.error_validate_vacancy")) unless blacklist.empty?

    blacklist
  end
end