class CreateReleases < ActiveRecord::Migration[8.0]
  def up
    create_table :releases, id: :uuid do |t|
      t.integer :episode_id, null: false
      t.references :tv_show, null: false, foreign_key: true, type: :uuid
      t.references :distributor, null: false, foreign_key: true, type: :uuid

      t.string   :episode_name
      t.date     :airdate
      t.datetime :airstamp
      t.integer  :runtime
      t.integer  :season
      t.integer  :number

      t.timestamps
    end
  end

  def down
    drop_table :releases
  end
end
