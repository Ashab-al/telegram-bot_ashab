class Api::User::SetBonusInteractor < ActiveInteraction::Base
  integer :id, presence: true
  integer :bonus, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def execute
    user = User.find_by(id: id)
    return errors.add(:user, :invalid) unless user
    
    user.update(bonus: bonus)
  end
end