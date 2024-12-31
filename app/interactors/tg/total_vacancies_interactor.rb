class Tg::TotalVacanciesInteractor  < ActiveInteraction::Base

  def execute
    categories = Category.includes(:vacancies).all
    
    formation_text(categories)
  end

  def formation_text(categories)
    text = I18n.t('vacancy.total_vacancies.all_vacancies_size', size: Vacancy.count)

    categories.each do |category|
      text += if category.vacancies.size.positive?
                I18n.t('vacancy.total_vacancies.category_and_vacancy_size_bold', 
                        name: category.name, size: category.vacancies.size)
              else
                I18n.t('vacancy.total_vacancies.category_and_vacancy_size', 
                  name: category.name, size: category.vacancies.size)
              end
    end

    text
  end
end