class AddFieldsToManagers < ActiveRecord::Migration[8.0]
  def change
    add_column :managers, :game_notifications, :boolean, default: false
    add_column :managers, :weekly_notifications, :boolean, default: false
  end
end
