class CreateGroceryListItems < ActiveRecord::Migration[5.1]
  def change
    create_table :grocery_list_items, id: :uuid do |t|
      t.string :ingredient_ids, array: true
      t.string :edited_name
      t.string :orig_name, null: false
      t.references :grocery_list, type: :uuid, index: true, foreign_key: { on_delete: :cascade }
      t.references :meal, type: :uuid, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
