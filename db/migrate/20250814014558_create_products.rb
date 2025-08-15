class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.references :created_by_admin, null: false, foreign_key: { to_table: :admins }

      t.timestamps
    end

    add_index :products, :name, unique: true
  end
end
