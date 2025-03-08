class AddChangeNullCategoryIdToVacancies < ActiveRecord::Migration[7.0]
  def change
    change_column_null :vacancies, :category_id, false
  end
end
