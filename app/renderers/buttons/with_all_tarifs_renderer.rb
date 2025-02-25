class Buttons::WithAllTarifsRenderer
  POINTS_REGEX = Regexp.new(I18n.t('points').values.uniq.map { |v| "(#{v})" }.join('|').gsub('%{count}', "\\d+"))
  CURRENCY = 'XTR'
  TARIFS_PRICES = {
    10 => 31, 
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