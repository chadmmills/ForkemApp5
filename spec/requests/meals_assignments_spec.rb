require 'rails_helper'

RSpec.describe "Meal Day Assignments" do
  describe "Assignment multiple meals per day" do
    it 'should assign multiple meals per day' do
      mealbook_id = create(:mealbook).id
      meal = create(:meal, mealbook_id: mealbook_id)
      assignment_date = Date.today
      MealAssignment.create! meal: meal, assigned_on: assignment_date

      params = {
        meal_id: meal.id,
        weekdate: assignment_date.to_s
      }

      expect do
        post "/meal-assignments", params: params
      end.to change(MealAssignment, :count).from(1).to(2)
    end

    it 'should limit assignments per day to 3' do
      mealbook_id = create(:mealbook).id
      meal = create(:meal, mealbook_id: mealbook_id)
      assignment_date = Date.today
      MealAssignment.create! meal: meal, assigned_on: assignment_date
      MealAssignment.create! meal: meal, assigned_on: assignment_date
      MealAssignment.create! meal: meal, assigned_on: assignment_date

      params = {
        meal_id: meal.id,
        weekdate: assignment_date.to_s
      }

      post "/meal-assignments", params: params
      expect(response.code).to eq "422"
    end
  end
end
