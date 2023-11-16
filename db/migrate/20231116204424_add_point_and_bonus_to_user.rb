class AddPointAndBonusToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :point, :integer
    add_column :users, :bonus, :integer
  end
end
