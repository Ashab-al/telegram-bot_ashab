class Api::User::GetUserInteractor < ActiveInteraction::Base
  integer :id, presence: true

  def execute
    user = User.find_by(id: id)
    return errors.add(:user, :invalid) unless user

    user
  end
end