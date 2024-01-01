class RemoveTechSpetsSiteFromCategory < ActiveRecord::Migration[7.0]
  def change
    remove_column :categories, :tech_spets, :integer
    remove_column :categories, :site, :integer
  end
end
