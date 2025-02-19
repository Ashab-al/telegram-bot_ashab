class Buttons::WithAllCategories
  MAX_COUNT_BUTTON_IN_LINE=2
  
  def initialize(subscribed_categories)
    @subscribed_categories = subscribed_categories
    @all_category = Category.all
    @buttons = []
  end

  def call
    two_button = []
    @all_category.each do | category |
      @category = category

      two_button << {
        text: erb_render("button/two_button_text", binding),
        callback_data: "#{@category.name.sub(' ', '_')}"
      }

      if two_button.size == MAX_COUNT_BUTTON_IN_LINE || @category == @all_category.last
        @buttons << two_button
        two_button = []
      end
    end

    @buttons << [{text: erb_render("button/get_vacancies", binding), callback_data: "get_vacancies_start_1"}]
    
    {inline_keyboard: @buttons}
  end

  private

  def erb_render(action, new_binding)
    ERB.new(File.read(Rails.root.join "app/views/telegram_webhooks/#{action}.html.erb")).result(new_binding)
  end
end