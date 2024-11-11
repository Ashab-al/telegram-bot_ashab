FactoryBot.define do 
  factory :vacancy do 
    title { "Тех-спец" }
    description { "Описание" }
    contact_information { "@username" }
    platform_id { "123123" }
    source { "TG" }
    
  end
end