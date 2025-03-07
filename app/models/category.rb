class Category < ApplicationRecord
  has_many :subscriptions
  has_many :user, through: :subscriptions
  has_many :vacancies

  validates :name, presence: true
end
