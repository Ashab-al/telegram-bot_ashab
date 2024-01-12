Yookassa.configure do |config|
  config.shop_id = Rails.application.secrets.yookassa_api[:shop_id] 
  config.api_key = Rails.application.secrets.yookassa_api[:api_key] 
end