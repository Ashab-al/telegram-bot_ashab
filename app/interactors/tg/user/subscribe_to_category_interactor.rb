class Tg::User::SubscribeToCategoryInteractor < ActiveInteraction::Base
  object :user, presence: true
  object :category, presence: true

  def execute
    user.subscriptions.create(category: category)
    user
  end
end