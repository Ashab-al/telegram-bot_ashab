class Vacancy < ApplicationRecord
  validates :category_title, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :contact_information, presence: true 
end
