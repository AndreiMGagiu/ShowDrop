class AddUniqueIndexToDistributorsNameAndCountry < ActiveRecord::Migration[8.0]
  def change
    add_index :distributors, [:name, :country], unique: true, name: 'index_distributors_on_name_and_country'
  end
end
