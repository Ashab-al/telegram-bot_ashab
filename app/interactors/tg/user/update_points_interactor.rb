class Tg::User::UpdatePointsInteractor < ActiveInteraction::Base
  object :user, presence: true
  integer :points, presence: true
  integer :stars, presence: true

  # validates :points, numericality: { greater_than_or_equal_to: 1 }
  # validates :stars, numericality: { greater_than_or_equal_to: 1 }

  def execute
    user.update(point: user.point + points)

    Tg::SendInfoAboutNewPaymentInteractor.run(name: user.name, points: points, stars: stars)

    user
  end
end