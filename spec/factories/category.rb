FactoryBot.define do 
  factory :category do 
    name { "Тех-спец" }
  end

  factory :category_2, class: 'Vacancy' do 
    name { "Дизайнер" }
  end

  factory :category_3, class: 'Vacancy' do 
    name { "Маркетолог" }
  end
end