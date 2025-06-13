class CreateTvShows < ActiveRecord::Migration[8.0]
  def up
    create_table :tv_shows, id: :uuid do |t|
      t.integer :provider_identifier, null: false
      t.string  :name, null: false
      t.string  :language, null: false
      t.string  :status
      t.float   :rating
      t.text    :summary
      t.string  :image

      t.timestamps
    end
  end

  def down
    drop_table :tv_shows
  end
end
