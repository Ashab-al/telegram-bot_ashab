class Tg::User::StatusChangesForBlockInteractor < ActiveInteraction::Base
  object :user

  def execute
    user.update({:bot_status => User::BOT_STATUS_BLOCKED})

    user
  end
end