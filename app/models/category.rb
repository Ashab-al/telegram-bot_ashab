class Category < ApplicationRecord
  has_many :subscriptions
  has_many :user, through: :subscriptions
  has_many :vacancies

  validates :name, uniqueness: true,
                   presence: true
end
