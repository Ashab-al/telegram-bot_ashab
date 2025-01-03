class Tg::TotalVacanciesInteractor  < ActiveInteraction::Base

  def execute    
    formation_text
  end

  def formation_text
    vacancy_size = 0
    category_size_text = Category.pluck(Arel.sql("name"), Arel.sql("(SELECT count(*) FROM vacancies WHERE vacancies.category_id = categories.id)"))
      .each_with_index
      .reduce("") do |text, (row)|
        vacancy_size += row.second
        text += I18n.t('vacancy.total_vacancies.category_and_vacancy_size', name: row.second.positive? ? "<b>#{row.first}</b>" : row.first, size: row.second, shift: "\n")
      end
    
    I18n.t('vacancy.total_vacancies.all_vacancies_size', size: vacancy_size, shift: "\n") + category_size_text
  end
end


