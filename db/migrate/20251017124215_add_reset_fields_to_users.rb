class AddResetFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :managers, :reset_password_code, :string
    add_column :managers, :reset_password_sent_at, :datetime
    add_index :managers, :reset_password_code, unique: true
  end
end
