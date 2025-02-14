class Tg::Category::FindUserSubscribeInteractor < ActiveInteraction::Base
  object :user, presence: true

  def execute
    Categories::FindByUserQuery.new({subscribed_categories: :true}, user).call
  end
end