class Categories::FindByUserQuery

  def initialize(params, relation = User.all)
    @params = params
    @relation = relation
  end

  def call
    filter_by_bot_status
  end

  private

  def filter_by_bot_status
    if @params[:bot_status].present?
      @relation = @relation.pluck(Arel.sql("(select count(*) from users where users.bot_status = '#{@params[:bot_status].to_s}')"))
    end
  end
end