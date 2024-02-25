class AddSourcePlatformIdToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :source, :string
    add_column :vacancies, :platform_id, :string
  end
end
