class CreateIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :ingredients, id: :uuid do |t|
      t.string :name, null: false
      t.string :measurement_unit
      t.decimal :quantity
      t.references :meal, type: :uuid, index: true, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
