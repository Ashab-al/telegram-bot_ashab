class Api::Category::DestroyCategoryInteractor < ActiveInteraction::Base
  integer :id, presence: true

  def execute
    category = Category.find_by(id: id)
    return errors.add(:category, :invalid) unless category

    category.destroy
  end
end