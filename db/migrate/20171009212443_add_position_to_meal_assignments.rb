class AddPositionToMealAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :meal_assignments, :position, :integer, min: 0, max: 2, null: false, index: true, default: 0
  end
end
