# Migration to rename the 'password' column to 'password_digest' in the 'admins' table.
# This is typically done to support secure password storage using bcrypt,
# as 'password_digest' is the convention used by has_secure_password in Rails.
#
# Example:
#   Before: admins table has a 'password' column storing plain text passwords.
#   After:  admins table has a 'password_digest' column for storing hashed passwords.
#
# Migration version: 8.0
class RenameAdminPasswordToPasswordDigest < ActiveRecord::Migration[8.0]
  def change
    rename_column :admins, :password, :password_digest
  end
end
