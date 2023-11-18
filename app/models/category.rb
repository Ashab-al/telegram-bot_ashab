class Category < ApplicationRecord
  has_many :subscriptions
  has_many :user, through: :subscriptions
end
