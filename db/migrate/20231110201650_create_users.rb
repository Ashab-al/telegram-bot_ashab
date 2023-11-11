class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :email
      t.integer :phone
      t.integer :platform_id

      t.timestamps
    end
  end
end
