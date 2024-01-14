class Api::YandexKassaCallbackController < ApplicationController
  def index
    puts "-------------INDEX-------------"
    p request
    puts "-------------INDEX-------------"
    TelegramMessageService.new.send_payment_notification(request)
    render json: {"result":200}
  end
end
