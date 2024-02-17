class ChangeUserColumn < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :platform_id, :bigint
    change_column :users, :phone, :string
  end
end
