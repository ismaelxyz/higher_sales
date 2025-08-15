class AddCreatedByAdminToCategories < ActiveRecord::Migration[8.0]
  def change
    add_reference :categories, :created_by_admin, null: false, foreign_key: { to_table: :admins }
  end
end
