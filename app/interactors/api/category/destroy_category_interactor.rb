class Api::Category::DestroyCategoryInteractor < ActiveInteraction::Base
  string :name, presence: true
  integer :category_id, presence: true

  def execute
    category = Category.find_by(id: category_id)
    return errors.add(:category, :invalid) unless category

    category.destroy
  end
end