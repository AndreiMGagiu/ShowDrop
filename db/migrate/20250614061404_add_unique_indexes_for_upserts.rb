class AddUniqueIndexesForUpserts < ActiveRecord::Migration[8.0]
  def change
    add_index :tv_shows, :provider_identifier, unique: true
    add_index :distributors, :name, unique: true
    add_index :releases, :episode_id, unique: true
  end
end
