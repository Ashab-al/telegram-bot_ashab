class Tg::TotalVacanciesInteractor  < ActiveInteraction::Base

  def execute
    vacancies_by_category = Vacancy.group(:category_title).count
    text = "<b>Всего вакансий отправлено:</b> #{Vacancy.count} ⚡️\n"
    
    Category.all.each do |category|  
      category_vacancies_count = vacancies_by_category[category.name] || 0
      text += if category_vacancies_count.positive?
                "<b>#{category.name}:</b> #{category_vacancies_count}\n"
              else
                "#{category.name}: #{category_vacancies_count}\n"
              end
    end
    
    text 
  end
end