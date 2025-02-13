class Tg::User::FindOrCreateWithUpdateByPlatformIdInteractor < ActiveInteraction::Base
  integer :id, presence: true
  string :username, default: ""
  string :name, default: ""
  integer :point, default: 0
  integer :bonus, default: 5


  def execute
    user = User.find_by(platform_id: id)

    unless user
      new_user = User.create(
        name: name,
        username: username,
        platform_id: id,
        point: point,
        bonus: bonus
      )

      return {user: new_user, status: :new_user}
    end
    
    user.update({:bot_status => "works"}) if user.bot_status != "works"
    
    {user: user, status: :old_user}
  end
end
