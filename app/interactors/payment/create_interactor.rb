class Payment::CreateInteractor < ActiveInteraction::Base
  string :title
  string :tarif, presence: true
  string :chat_id, presence: true
  object :bot, class: Telegram::Bot::Client

  
  def execute
    return errors.add(:tarif, :invalid) if tarifs[:"#{tarif}"].nil? 
    
    bot.send_invoice(
      chat_id: chat_id,
      title: "#{title} #{tarifs[:"#{tarif}"][:description]}",
      description: tarifs[:"#{tarif}"][:description],
      payload: tarifs[:"#{tarif}"][:points],
      currency: 'XTR',
      prices: [
        Telegram::Bot::Types::LabeledPrice.new(label: tarifs[:"#{tarif}"][:description], 
                                               amount: tarifs[:"#{tarif}"][:cost])
      ]
    )
  end

  private

  def tarifs
    {
      "#{I18n.t('buttons.by_points.point_10_callback')}": {
        :cost => 30,
        :description => "#{I18n.t('buttons.by_points.point_10_callback')}",
        :points => 10
      },
      "#{I18n.t('buttons.by_points.point_30_callback')}": {
        :cost => 85,
        :description => "#{I18n.t('buttons.by_points.point_30_callback')}",
        :points => 30
      },
      "#{I18n.t('buttons.by_points.point_50_callback')}": {
        :cost => 135,
        :description => "#{I18n.t('buttons.by_points.point_50_callback')}",
        :points => 50
      },
      "#{I18n.t('buttons.by_points.point_100_callback')}": {
        :cost => 255,
        :description => "#{I18n.t('buttons.by_points.point_100_callback')}",
        :points => 100
      },
      "#{I18n.t('buttons.by_points.point_150_callback')}": {
        :cost => 360,
        :description => "#{I18n.t('buttons.by_points.point_150_callback')}",
        :points => 150
      },
      "#{I18n.t('buttons.by_points.point_200_callback')}": {
        :cost => 450,
        :description => "#{I18n.t('buttons.by_points.point_200_callback')}",
        :points => 200
      }
    }
  end
end