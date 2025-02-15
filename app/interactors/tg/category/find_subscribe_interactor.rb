class Tg::Category::FindSubscribeInteractor < ActiveInteraction::Base
  object :user, presence: true

  def execute
    Categories::FindByUserQuery.new({subscribed_categories: :true}, user).call
  end
end