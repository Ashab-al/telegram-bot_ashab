class Tg::User::ByPlatformIdInteractor < ActiveInteraction::Base
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

    {user: user, status: :old_user}
  end
end
