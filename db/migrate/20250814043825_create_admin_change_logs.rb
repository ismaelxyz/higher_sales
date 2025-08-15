class CreateAdminChangeLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_change_logs do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :table_name
      t.string :target_type
      t.text :old_value
      t.text :new_value

      t.timestamps
    end
  end
end
