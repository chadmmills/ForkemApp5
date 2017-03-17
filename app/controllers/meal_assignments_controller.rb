class MealAssignmentsController < ApplicationController
  def create
    MealAssignment.create!(
      assigned_on: params[:weekdate],
      meal_id: params[:meal_id],
    )

    render json: {
      params: params,
      mealbook: MealbookPlanner.new(
        mealbook: Mealbook.first,
        current_date: Date.parse(params[:weekdate])
      )
    }
  end

  def destroy
    mealbook = Mealbook.first
    assignment = mealbook.meal_assignments.find(params[:id])
    assignment.destroy!
    render json: {
      params: params,
      mealbook: MealbookPlanner.new(
        mealbook: Mealbook.first,
        current_date: assignment.assigned_on,
      )
    }

  end
end
