class RemoveCategoryTitleFromVacancy < ActiveRecord::Migration[7.0]
  def change
    remove_column :vacancies, :category_title, :string
  end
end
