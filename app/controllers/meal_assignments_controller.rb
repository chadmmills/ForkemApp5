class MealAssignmentsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    mealbook = Mealbook.find_mealbook_for_meal_id(params[:meal_id])
    meal_assigner = MealAssigner.new(
      mealbook_assignment: mealbook,
      position: params[:position],
      assignment_date: params[:weekdate],
    )

    if (meal_assigner.save)
      render json: {
        params: params,
        mealbook: MealbookPlanner.new(
          mealbook: Meal.find(params[:meal_id]).mealbook,
          current_date: Date.parse(params[:weekdate]).beginning_of_week
        )
      }
    else
      render json: {}, status: 422
    end
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
