class CreateDistributors < ActiveRecord::Migration[8.0]
  def up
    create_table :distributors, id: :uuid do |t|
      t.string :name, null: false
      t.string :country
      t.string :kind

      t.timestamps
    end
  end

  def down
    drop_table :distributors
  end
end
