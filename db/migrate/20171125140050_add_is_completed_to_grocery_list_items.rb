class AddIsCompletedToGroceryListItems < ActiveRecord::Migration[5.1]
  def change
    add_column :grocery_list_items, :is_completed, :bool, null: false, default: false
  end
end
