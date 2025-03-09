class Api::Vacancy::CreateVacancyInteractor < ActiveInteraction::Base
  string :title, presence: true
  string :description, presence: true
  string :contact_information, presence: true
  integer :platform_id, presence: true
  string :source, presence: true
  integer :category_id, presence: true

  def execute
    vacancy = Vacancy.create(vacancy_params)

    if vacancy.save
      return vacancy
    end

    errors.add(:vacancy, :invalid)
  end

  def vacancy_params 
    {
      title: title,
      description: description,
      contact_information: contact_information,
      platform_id: platform_id,
      source: source,
      category_id: category_id
    }
  end
end