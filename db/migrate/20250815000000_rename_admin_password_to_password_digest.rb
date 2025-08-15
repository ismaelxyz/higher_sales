class RenameAdminPasswordToPasswordDigest < ActiveRecord::Migration[8.0]
  def change
    rename_column :admins, :password, :password_digest
  end
end
