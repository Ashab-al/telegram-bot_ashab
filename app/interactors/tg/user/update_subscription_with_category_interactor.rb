class Tg::User::UpdateSubscriptionWithCategoryInteractor < ActiveInteraction::Base
  object :user, presence: true
  string :category_name, presence: true
  array :subscribed_categories, presence: true

  def execute
    category = Category.find_by(name: category_name)
    
    return errors.add(:invalid, :category_name) unless category

    if subscribed_categories.include?(category)
      unsubscribe = Tg::User::UnsubscribeFromCategoryInteractor.run(user: user, category: category)
      return errors.add(:unsubscribe, unsubscribe.errors) if unsubscribe.errors.present?
      
      return { status: :unsubscribe, result: unsubscribe.result } 
    else
      subscribe = Tg::User::SubscribeToCategoryInteractor.run(user: user, category: category)
      return errors.add(:subscribe, subscribe.errors) if subscribe.errors.present?

      return { status: :subscribe, result: subscribe.result }
    end
  end
end