class Ingredient < ApplicationRecord
  attribute :_delete, :boolean

  belongs_to :meal

  validates :name, presence: true

  class << self
    def grocery_list_json_for_date_range(mealbook_id, start_date, end_date)
      select("SUM(quantity) as total_quantity, measurement_unit, ingredients.name")
        .select("array_agg(ingredients.id) as ingredient_ids")
        .select("min(meal_assignments.assigned_on) as first_assigned")
        .joins(meal: :meal_assignments)
        .where(meals: { mealbook_id: mealbook_id })
        .where(meal_assignments: { assigned_on: start_date..end_date })
        .group("measurement_unit, ingredients.name").as_json(
      only: [:total_quantity, :measurement_unit, :name, :ingredient_ids, :first_assigned]
      )
    end
  end
end
