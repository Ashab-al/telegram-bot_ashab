class AddCategoryToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :category, :string
  end
end
