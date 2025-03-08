class Api::Vacancy::CheckAndCreateVacancyThenSendToUsersInteractor < ActiveInteraction::Base
  string :category_title, presence: true
  string :title, presence: true
  string :description, presence: true
  string :contact_information, presence: true
  integer :platform_id, presence: true
  string :source, presence: true

  def execute
    blacklist = Api::Vacancy::BlackListCheckInteractor.run(platform_id: platform_id, contact_information: contact_information)
    return errors.add(:blacklist, blacklist.errors) if blacklist.errors.present?
    
    category = Category.find_by(name: category_title)
    
    return errors.add(:category, :invalid) unless category

    vacancy = Api::Vacancy::CreateVacancyInteractor.run(
      category_id: category.id,
      title: title,
      description: description,
      contact_information: contact_information,
      platform_id: platform_id,
      source: source
      )
    return errors.add(:vacancy, vacancy.errors) if vacancy.errors.present?

    send_vacancy = Tg::Vacancy::SendVacancyToUsersInteractor.run(vacancy: vacancy.result)
    return errors.add(:send_vacancy, send_vacancy.errors) if send_vacancy.errors.present?
    
    vacancy.result
  end
end