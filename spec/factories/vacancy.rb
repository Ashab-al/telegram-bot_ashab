FactoryBot.define do 
  factory :vacancy do 
    category_title { "Тех-спец" }
    title { "Тех-спец" }
    description { "Описание" }
    contact_information { "@username" }
    platform_id { "123123" }
  end
end