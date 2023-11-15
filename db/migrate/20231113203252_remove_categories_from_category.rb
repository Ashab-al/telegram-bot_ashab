class RemoveCategoriesFromCategory < ActiveRecord::Migration[7.0]
  def change
    remove_column :categories, :target, :integer
    remove_column :categories, :copyright, :integer
    remove_column :categories, :design, :integer
    remove_column :categories, :assistant, :integer
    remove_column :categories, :marketing, :integer
    remove_column :categories, :sales, :integer
  end
end
