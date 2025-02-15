class Categories::FindByUserQuery

  def initialize(params, relation = Category.all)
    @params = params
    @relation = relation
  end

  def call
    filter_by_users_bot_status
    filter_by_subscribed_categories

    @relation
  end

  private

  def filter_by_users_bot_status
    if @params[:bot_status].present?
      @relation = @relation.where(Subscription.where(user: User.where(bot_status: @params[:bot_status])).exists?)
    end
  end

  def filter_by_subscribed_categories
    if @params[:subscribed_categories].present?
      @relation = @relation.subscriptions.includes(:category).map(&:category)
    end
  end
end