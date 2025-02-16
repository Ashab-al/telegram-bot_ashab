class Categories::FindByUserQuery

  def initialize(params, relation = Category.all)
    @params = params
    @relation = relation
  end

  def call
    filter_by_subscribed_categories

    @relation
  end

  private

  def filter_by_subscribed_categories
    if @params[:subscribed_categories].present?
      @relation = @relation.where(Subscription.where(user_id: @params[:user_id]).select(:category_id))
    end
  end
end