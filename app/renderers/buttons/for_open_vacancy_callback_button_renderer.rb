class Buttons::ForOpenVacancyCallbackButtonRenderer

  def initialize(message_id, vacancy_id)
    @message_id = message_id
    @vacancy_id = vacancy_id
  end

  def call
    { 
      text: Tg::Common.erb_render("button/get_contact"), 
      callback_data: "mid_#{@message_id}_bdid_#{@vacancy_id}"
    }
  end
end