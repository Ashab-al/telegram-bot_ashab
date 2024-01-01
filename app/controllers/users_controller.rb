class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.last
    TelegramMessageService.new(@user.platform_id).send_message("Новое сообщение")
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
