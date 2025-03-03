class Tg::User::UpdateSubscriptionWithCategoryInteractor < ActiveInteraction::Base
  object :user, presence: true
  string :category_name, presence: true
  array :subscribed_categories, presence: true

  def execute
    category = Category.find_by(name: category_name)

    return errors.add(:invalid, :category) unless category

    if subscribed_categories.include?(category)
      user.subscriptions.find_by(category: category).destroy
      { status: :unsubscribe, result: user }
    else
      user.subscriptions.create(category: category)
      { status: :subscribe, result: user }
    end
  end
end
