class CreateMealbookUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :mealbook_users, id: :uuid do |t|
      t.references :mealbook, type: :uuid, index: true, foreign_key: { on_delete: :cascade }
      t.references :user, type: :uuid, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
