# Migration to add a reference to the `admins` table in the `categories` table.
# This adds a non-nullable `created_by_admin_id` column to `categories`, establishing
# a foreign key relationship to the `admins` table. This allows tracking which admin
# created each category.
class AddCreatedByAdminToCategories < ActiveRecord::Migration[8.0]
  def change
    add_reference :categories, :created_by_admin, null: false, foreign_key: { to_table: :admins }
  end
end
