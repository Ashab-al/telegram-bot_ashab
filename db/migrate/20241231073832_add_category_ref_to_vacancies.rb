class AddCategoryRefToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_reference :vacancies, :category, null: false, foreign_key: true
  end
end
