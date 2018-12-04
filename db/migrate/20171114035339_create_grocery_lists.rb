class CreateGroceryLists < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto'

    create_table :grocery_lists, id: :uuid do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :mealbook_id, null: false, index: true

      t.timestamps
    end
  end
end
