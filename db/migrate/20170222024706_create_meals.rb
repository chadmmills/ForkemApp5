class CreateMeals < ActiveRecord::Migration[5.0]
  def change
    create_table :meals, id: :uuid do |t|
      t.string :name, null: false
      t.string :desc
      t.references :mealbook, type: :uuid, index: true, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
