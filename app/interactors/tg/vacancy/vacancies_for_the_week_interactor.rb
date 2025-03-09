class Tg::Vacancy::VacanciesForTheWeekInteractor < ActiveInteraction::Base
  object :user, presence: true

  QUANTITY_DAYS = 7
  DELAY = 3.0

  def execute
    subscribed_categories = Tg::Category::FindSubscribeInteractor.run(user: user).result

    return {status: :subscribed_categories_empty} if subscribed_categories.empty?

    vacancies = Vacancy.where(category_id: subscribed_categories.map(&:id)).
    where.not(platform_id: Blacklist.pluck(:contact_information)).
    where(created_at: QUANTITY_DAYS.days.ago..Time.now).order(created_at: :asc)

    return {status: :vacancy_list_empty} if vacancies.empty?

    {status: :ok, vacancies: vacancies}
  end
end