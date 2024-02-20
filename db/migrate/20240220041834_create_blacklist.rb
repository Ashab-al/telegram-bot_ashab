class CreateBlacklist < ActiveRecord::Migration[7.0]
  def change
    create_table :blacklists do |t|
      t.string :contact_information
      t.integer :complaint_counter

      t.timestamps
    end
  end
end
