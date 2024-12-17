FactoryBot.define do 
  factory :user do 
    name { "Я человек" }
    username { "username3123" }
    email { "example@gmail.com" }
    phone { "79999999999" }
    platform_id { "123154123231" }
    point { 1 }
    bonus { 2 }
    bot_status { "works" }
  end
end