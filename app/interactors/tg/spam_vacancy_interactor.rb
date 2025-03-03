class Tg::SpamVacancyInteractor < ActiveInteraction::Base
  integer :id, presence: true

  SPAM_VACANCY_REGEX = Regexp.new('^spam_mid_\d+_bdid_\d+')

  COMPLAINT_COUNTER = 2

  def execute
    vacancy = Vacancy.find_by(id: id)
    contact_information = vacancy.source == Tg::Constants::SOURCE ? vacancy.platform_id : vacancy.contact_information

    blacklist = Blacklist.find_or_create_by(contact_information: contact_information) do |blacklist|
      blacklist.complaint_counter = 0
    end

    return :blacklisted if blacklist.complaint_counter >= COMPLAINT_COUNTER

    blacklist.increment!(:complaint_counter)
  end
end
