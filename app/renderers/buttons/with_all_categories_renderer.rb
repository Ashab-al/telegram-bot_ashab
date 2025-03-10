class Buttons::WithAllCategoriesRenderer

  MAX_COUNT_BUTTON_IN_LINE = 2
  VACANSIES_START = "get_vacancies_start_"

  PAGINATION_START_REGEX = Regexp.new("^#{VACANSIES_START}\\d+")

  FIRST = 1
  
  def initialize(subscribed_categories)
    @subscribed_categories = subscribed_categories
  end

  def call
    all_category = Category.all
    buttons = []
    two_button = []

    all_category.each do | category |

      two_button << {
        text: Tg::Common.erb_render("button/two_button_text", {category: category, subscribed_categories: @subscribed_categories}),
        callback_data: "#{category.name.sub(' ', '_')}"
      }

      if two_button.size == MAX_COUNT_BUTTON_IN_LINE || category == all_category.last
        buttons << two_button
        two_button = []
      end
    end

    buttons << [{text: Tg::Common.erb_render("button/get_vacancies"), callback_data: VACANSIES_START + FIRST.to_s}]
    
    {inline_keyboard: buttons}
  end
end