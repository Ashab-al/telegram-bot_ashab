class TelegramMessageService
  def initialize(chat_id)
    @chat_id = chat_id
    @bot = Telegram::Bot::Client.new('token')  
  end

  def send_message(message_text)
    @bot.send_message(chat_id: @chat_id, text: message_text)
  end
end