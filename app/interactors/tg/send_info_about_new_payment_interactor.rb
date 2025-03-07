class Tg::SendInfoAboutNewPaymentInteractor < ActiveInteraction::Base
  string :name, presence: true
  integer :points, presence: true
  integer :stars, presence: true
  
  def execute
    Telegram.bot.send_message(
      chat_id: Rails.application.secrets.errors_chat_id, 
      text: Tg::Common.erb_render('payment_info_for_admin', { name: name, points: points, stars: stars })
    )   
  end
end