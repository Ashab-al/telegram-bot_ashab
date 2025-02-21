class Tg::User::UpdateSubscriptionWithCategoryInteractor < ActiveInteraction::Base
  object :user, presence: true
  string :category_name, presence: true
  array :subscribed_categories, presence: true

  def execute
    user = User.find_by(platform_id: id)
    category = Category.find_by(name: category_name)
    
    return errors.add(:invalid, :params) unless category || user
    
    if subscribed_categories.include?(category)
      user.subscriptions.find_by(category: category).destroy      
      return { status: :unsubscribe, result: user } 
    else
      user.subscriptions.create(category: category)
      return { status: :subscribe, result: user }
    end
  end
end