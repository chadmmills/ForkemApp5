class CreateMealAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :meal_assignments, id: :uuid do |t|
      t.date :assigned_on, null: false
      t.references :meal, type: :uuid, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
    add_index :meal_assignments, [:assigned_on, :meal_id], unique: true
  end
end
