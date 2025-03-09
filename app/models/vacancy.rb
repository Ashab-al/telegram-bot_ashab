class Vacancy < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates :contact_information, presence: true 

  belongs_to :category
end
