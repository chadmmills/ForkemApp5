require 'rails_helper'

RSpec.describe "Grocery List" do
  describe "Create" do
    it "should return persisted grocery list" do
      planner_id = create(:mealbook).id
      meal = create(:meal, mealbook_id: planner_id)
      create_list(:ingredient, 5, meal: meal)
      MealAssignment.create! assigned_on: Date.today - 1, meal: meal
      params = {}

      post "/planners/#{planner_id}/grocery-lists", params: params

      expect(response).to be_success
    end
  end
end
