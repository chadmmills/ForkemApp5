class Mealbook < ApplicationRecord
  has_many :meals #on_delete :cascade

  def meal_assignments(meal_assignment:MealAssignment)
    meal_assignment.where(meal_id: meals.select(:id))
  end

  def meals_assigned_within_range(date_range)
    meals.joins(:meal_assignments).
      select("meals.*, meal_assignments.id AS assignment_id").
      select("meal_assignments.assigned_on").
      where(meal_assignments: { assigned_on: date_range })
  end
end
