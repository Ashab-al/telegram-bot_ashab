class Tg::AdvertisementInteractor < ActiveInteraction::Base
  def execute
    { rows: Category.pluck(Arel.sql('name'),
                           Arel.sql('(SELECT count(*) FROM subscriptions WHERE subscriptions.category_id = categories.id)')) }
  end
end
