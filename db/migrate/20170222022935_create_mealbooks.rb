class CreateMealbooks < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp'

    create_table :mealbooks, id: :uuid do |t|
      t.string :name, null: false
      t.string :param, null: false

      t.timestamps
    end

    add_index :mealbooks, :param, unique: true
  end
end
