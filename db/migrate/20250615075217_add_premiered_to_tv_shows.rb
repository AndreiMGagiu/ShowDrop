class AddPremieredToTvShows < ActiveRecord::Migration[8.0]
  def change
    add_column :tv_shows, :premiered, :date
    add_index :tv_shows, :premiered
  end
end
