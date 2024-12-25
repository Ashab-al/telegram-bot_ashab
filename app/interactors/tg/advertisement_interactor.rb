class Tg::AdvertisementInteractor  < ActiveInteraction::Base

  def execute
    text = ""
    
    Category.all.each_with_index do |category, index|
      text += "#{index+1}. #{category.name}: #{category.user.size}\n"
    end
    
    text
  end
end