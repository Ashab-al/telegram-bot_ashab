class User < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :category, through: :subscriptions


  validates :username, uniqueness: true, 
                       allow_blank: true

  validates :platform_id, uniqueness: true, 
                          presence: true

  validates :name, presence: true

  validates :email, uniqueness: true, allow_blank: true

  validates :phone, uniqueness: true, allow_blank: true
end
