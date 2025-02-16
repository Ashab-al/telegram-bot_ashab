class User < ApplicationRecord
  BOT_STATUS_BLOCKED="bot_blocked"
  BOT_STATUS_WORKS="works"

  has_many :subscriptions, dependent: :destroy
  has_many :category, through: :subscriptions

  validates :username, uniqueness: true,
                       allow_blank: true

  validates :platform_id, uniqueness: true,
                          presence: true

  validates :email, uniqueness: true, allow_blank: true

  validates :phone, uniqueness: true, allow_blank: true

  scope :active_bot, ->() { where(BOT_STATUS: BOT_STATUS_WORKS) }
  scope :bot_blocked, ->() { where(BOT_STATUS: BOT_STATUS_BLOCKED) }
end
