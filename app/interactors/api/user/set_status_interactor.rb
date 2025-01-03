class Api::User::SetStatusInteractor < ActiveInteraction::Base
  integer :id, presence: true
  string :bot_status, presence: true, inclusion: { in: ["works", "bot_blocked"] }

  def execute
    user = User.find_by(id: id)
    return errors.add(:user, :invalid) unless user
    
    user.update(bot_status: bot_status)
    user
  end
end