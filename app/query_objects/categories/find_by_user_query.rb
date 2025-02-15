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
      @relation = @relation.subscriptions.includes(:category).map(&:category)
    end
  end
end