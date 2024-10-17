class Payment::CreateInteractor < ActiveInteraction::Base
  
  string :product_name, presence: true
  string :title, presence: true
  string :description, presence: true
  integer :price, presence: true
  string :chat_id, presence: true
  object :bot, class: Telegram::Bot::Client
  integer :points
  
  def execute
    user = User.find_by(platform_id: chat_id)
    return errors.add(:user, :invalid) unless user 

    bot.send_invoice(
      chat_id: user.platform_id,
      title: title,
      description: description,
      payload: "#{points}",
      currency: 'XTR',
      prices: [
        Telegram::Bot::Types::LabeledPrice.new(label: product_name, amount: price)
      ]
    )
  end
end