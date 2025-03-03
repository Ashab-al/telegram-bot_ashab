class Api::Category::UpdateCategoryInteractor < ActiveInteraction::Base
  string :name, presence: true
  integer :id, presence: true

  def execute
    category = Category.find_by(id: id)
    return errors.add(:category, :invalid) unless category

    category.update(name: name)
    category
  end
end
