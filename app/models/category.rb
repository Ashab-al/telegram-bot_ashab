class Category < ApplicationRecord
  has_many :subscriptions
  has_many :user, through: :subscriptions
  has_many :vacancies

  validates :name, presence: true

  scope :find_active_users_by_category_name, ->(name) { Category.find_by(name: name).user.active_bot }
end
