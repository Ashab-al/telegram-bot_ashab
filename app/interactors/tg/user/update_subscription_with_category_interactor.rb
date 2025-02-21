class Tg::User::UpdateSubscriptionWithCategoryInteractor < ActiveInteraction::Base
  integer :id
  string :category_name, presence: true

  def execute
    user = User.find_by(platform_id: id)
    category = Category.find_by(name: category_name)
    
    return errors.add(:invalid, :params) unless category || user
    
    if Tg::Category::FindSubscribeInteractor.run(user: user).result.include?(category)
      user.subscriptions.find_by(category: category).destroy      
      return { status: :unsubscribe, result: user } 
    else
      user.subscriptions.create(category: category)
      return { status: :subscribe, result: user }
    end
  end
end