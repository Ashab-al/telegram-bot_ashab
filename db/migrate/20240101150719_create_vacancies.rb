class CreateVacancies < ActiveRecord::Migration[7.0]
  def change
    create_table :vacancies do |t|
      t.string :category_title
      t.string :title
      t.text :description
      t.text :contact_information  

      t.timestamps
    end
  end
end
