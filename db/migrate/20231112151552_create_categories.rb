class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.integer :tech_spets
      t.integer :site
      t.integer :target
      t.integer :copyright
      t.integer :design
      t.integer :assistant
      t.integer :marketing
      t.integer :sales

      t.timestamps
    end
  end
end
