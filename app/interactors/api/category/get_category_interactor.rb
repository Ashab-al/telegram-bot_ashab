class Api::Category::GetCategoryInteractor < ActiveInteraction::Base
  integer :id, presence: true

  def execute
    category = Category.find_by(id: id)
    return errors.add(:category, :invalid) unless category

    category
  end
end
