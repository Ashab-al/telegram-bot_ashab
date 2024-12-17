class Api::Category::UpdateCategoryInteractor < ActiveInteraction::Base
  string :new_name, presence: true
  integer :category_id, presence: true

  def execute
    category = Category.find_by(id: category_id)
    return errors.add(:category, :invalid) unless category

    category.update(name: new_name)
  end
end