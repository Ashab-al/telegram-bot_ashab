FactoryBot.define do 
  factory :blacklist_new, class: 'Blacklist' do 
    complaint_counter { 0 }
  end

  factory :blacklist_full, class: 'Blacklist' do 
    complaint_counter { 2 }
  end
end