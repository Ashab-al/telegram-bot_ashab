class Categories::FindByUserQuery

  def initialize(params, relation = User.all)
    @params = params
    @relation = relation
  end

  def call
    filter_by_bot_status
    filter_by_subscribed_categories
  end

  private

  def filter_by_bot_status
    if @params[:bot_status].present?
      @relation = @relation.pluck(Arel.sql("(select count(*) from users where users.bot_status = '#{@params[:bot_status].to_s}')"))
    end
  end

  def filter_by_subscribed_categories
    if @params[:subscribed_categories].present?
      @relation = @relation.subscriptions.includes(:category).map(&:category)
    end
  end
end