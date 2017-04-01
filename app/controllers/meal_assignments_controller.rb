class MealAssignmentsController < ApplicationController
  def create
    MealAssignment.create!(
      assigned_on: params[:weekdate],
      meal_id: params[:meal_id],
    )

    render json: {
      params: params,
      mealbook: MealbookPlanner.new(
        mealbook: Meal.find(params[:meal_id]).mealbook,
        current_date: Date.parse(params[:weekdate]).beginning_of_week
      )
    }
  end

  def destroy
    assignment = MealAssignment.find(params[:id])
    assignment.destroy!
    render json: {
      params: params,
      mealbook: MealbookPlanner.new(
        mealbook: assignment.meal.mealbook,
        current_date: assignment.assigned_on.beginning_of_week,
      )
    }
  end
end
