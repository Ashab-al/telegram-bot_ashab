class Pagination::GetVacanciesSliceInteractor < ActiveInteraction::Base
  array :subscribed_categories, presence: true
  integer :batch_start, default: 0

  QUANTITY_DAYS = 700
  QUANTITY_VACANCIES = 2
  MINIMUM_SIZE = 1

  def execute
    subscribed_categories_name = subscribed_categories.map(&:name)
    return {status: :subscribed_categories_empty} if subscribed_categories_name.empty?

    vacancy_list = Vacancy.where(category_title: subscribed_categories_name).
    where.not(platform_id: Blacklist.pluck(:contact_information)).
    where(created_at: QUANTITY_DAYS.days.ago..Time.now).order(created_at: :asc)

    return {status: :vacancy_list_empty} if vacancy_list.empty?
    
    batch = vacancy_list.to_a.slice(batch_start, QUANTITY_VACANCIES)

    data = {
      status: true, 
      batch: batch,
      last_item_number: vacancy_list.index(batch&.last).next,
      full_size: vacancy_list.size
    }

    if batch.nil? || batch&.size < MINIMUM_SIZE
      data[:status] = :full_sended
      data.delete(:batch)
      return data
    end
    
    data
  end
end