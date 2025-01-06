FactoryBot.define do 
  factory :vacancy do 
    title { "Тех-спец" }
    description { "Описание" }
    contact_information { "@username" }
    platform_id { "123123" }
    source { "tg_chat" }
  end

  factory :vacancy_2, class: 'Vacancy'do 
    title { "Дизайн" }
    description { "Описание2" }
    contact_information { "@username2" }
    platform_id { "3231321" }
    source { "tg_chat" }
  end
end