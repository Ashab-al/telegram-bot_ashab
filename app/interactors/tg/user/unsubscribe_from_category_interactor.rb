class Tg::User::UnsubscribeFromCategoryInteractor < ActiveInteraction::Base
  object :user, presence: true
  object :category, presence: true

  def execute
    user.subscriptions.find_by(category: category).destroy
    user
  end
end