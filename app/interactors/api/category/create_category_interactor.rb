class Api::Category::CreateCategoryInteractor < ActiveInteraction::Base
  string :name, presence: true

  def execute
    category = Category.new(name: name)
    return errors.add(:category, :invalid) unless category.save

    category
  end
end
