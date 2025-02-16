FactoryBot.define do 
  factory :vacancy do 
    title { "Тех-спец" }
    description { "Описание" }
    source { "tg_chat" }
    sequence(:contact_information) { |n| "@username#{n}" }
    sequence(:platform_id) { |n| "1231541232#{n}" }
  end

  factory :vacancy_2, class: 'Vacancy'do 
    title { "Дизайн" }
    description { "Описание2" }
    source { "tg_chat" }
    sequence(:contact_information) { |n| "@username#{n}" }
    sequence(:platform_id) { |n| "1231541232#{n}" }
  end
end