class Tg::User::FindOrCreateWithUpdateByPlatformIdInteractor < ActiveInteraction::Base
  hash :chat, presence: true do 
    integer :id, presence: true
    string :first_name, default: ""
    string :username, default: ""
  end
  integer :point, default: User::DEFAULT_POINT
  integer :bonus, default: User::DEFAULT_BONUS


  def execute
    user = User.find_by(platform_id: chat[:id])

    unless user
      new_user = User.create(
        name: chat[:first_name],
        username: chat[:username],
        platform_id: chat[:id],
        point: point,
        bonus: bonus,
        bot_status: User::BOT_STATUS_WORKS
      )

      Tg::SendAnalyticsInteractor.run(user: new_user)

      return {user: new_user, status: :new_user}
    end
    
    user.update({:bot_status => User::BOT_STATUS_WORKS}) if user.bot_status != User::BOT_STATUS_WORKS
    
    {user: user, status: :old_user}
  end
end
