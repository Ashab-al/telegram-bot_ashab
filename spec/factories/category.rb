FactoryBot.define do
  factory :category, class: 'Category' do
    name { 'Тех-спец' }
  end

  factory :category_2, class: 'Category' do
    name { 'Дизайнер' }
  end

  factory :category_3, class: 'Category' do
    name { 'Маркетолог' }
  end

  factory :category_for_list, class: 'Category' do
    sequence(:name) { |n| "Маркетолог #{n}" }
  end
end
