FactoryBot.define do 
  factory :user do 
    name { "Я человек" }
    point { 1 }
    bonus { 2 }
    bot_status { "works" }
    sequence(:username) { |n| "username#{n}" }
    sequence(:email) { |n| "example#{n}@gmail.com" }
    sequence(:phone) { |n| "79999999999#{n}" }
    sequence(:platform_id) { |n| "1231541232#{n}" }
  end
end