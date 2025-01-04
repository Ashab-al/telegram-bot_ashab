class Tg::TotalVacanciesInteractor  < ActiveInteraction::Base

  def execute    
    {
      rows: Category.pluck(Arel.sql("name"), Arel.sql("(SELECT count(*) FROM vacancies WHERE vacancies.category_id = categories.id)")), 
      vacancy_size: Vacancy.count
    }
  end
end