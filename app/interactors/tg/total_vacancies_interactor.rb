class Tg::TotalVacanciesInteractor  < ActiveInteraction::Base

  def execute
    categories = Category.includes(:vacancies).all
    
    formation_text(categories)
  end

  def formation_text(categories)
    text = I18n.t('vacancy.total_vacancies.all_vacancies_size', size: Vacancy.count)

    categories.each do |category|
      text += I18n.t('vacancy.total_vacancies.category_and_vacancy_size', name: category.vacancies.size.positive? ? "<b>#{category.name}</b>" : category.name, size: category.vacancies.size)
    end

    text
  end
end