class CreateImages < ActiveRecord::Migration[8.0]
  def change
    create_table :images do |t|
      t.string :path
      t.references :product, null: false, foreign_key: { to_table: :products }

      t.timestamps
    end
  end
end
