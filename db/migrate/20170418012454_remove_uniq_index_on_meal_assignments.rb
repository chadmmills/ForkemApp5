class RemoveUniqIndexOnMealAssignments < ActiveRecord::Migration[5.0]
  def change
    remove_index :meal_assignments, name: "index_meal_assignments_on_assigned_on_and_meal_id"

    add_index :meal_assignments, [:assigned_on, :meal_id]
  end
end
