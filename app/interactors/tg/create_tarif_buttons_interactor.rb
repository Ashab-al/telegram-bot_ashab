class Tg::CreateTarifButtonsInteractor < ActiveInteraction::Base
  TARIFS_PRICES = {
    10 => 30, 
    30 => 85, 
    50 => 135, 
    100 => 255, 
    150 => 360, 
    200 => 450
  }

  def execute
    TARIFS_PRICES.keys.map do | tarif | 
      @tarif = tarif
      [{ text: erb_render("points/tarif_name", binding), callback_data: erb_render("points/tarif_callback", binding) }]
    end
  end

  private

  def erb_render(action, new_binding)
    ERB.new(File.read(Rails.root.join "app/views/telegram_webhooks/#{action}.html.erb")).result(new_binding)
  end
end