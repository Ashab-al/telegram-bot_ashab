class Buttons::WithAllTarifsRenderer
  TARIFS_PRICES = {
    10 => 1, 
    30 => 85, 
    50 => 135, 
    100 => 255, 
    150 => 362, 
    200 => 450
  }

  def call
    TARIFS_PRICES.map do | tarif, price | 
      @tarif = tarif
      @price = price
      [{ text: Tg::Common.erb_render("points/tarif_name", binding), callback_data: Tg::Common.erb_render("points/tarif_callback", binding) }]
    end
  end
end