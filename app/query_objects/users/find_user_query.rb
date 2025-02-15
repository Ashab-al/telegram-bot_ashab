class Users::FindUserQuery

  def initialize(params, relation = User.all)
    @params = params
    @relation = relation
  end

  def call
    filter_users_by_bot_status

    @relation
  end

  private

  def filter_users_by_bot_status
    if @params[:bot_status].present?
      @relation = @relation.where(bot_status: @params[:bot_status])
    end
  end
end