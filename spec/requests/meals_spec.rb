require 'rails_helper'

RSpec.describe "Meals" do
  describe "creating a meal" do
    it "should save the meal with valid params" do
      mealbook_id = create(:mealbook).id
      params = {
        "meal"=>{
          "desc"=>"### Test",
          "ingredients"=>[],
          "name"=>"Test",
          "mealbook_id" => mealbook_id
        },
      }
      expect do
        post "/meals", params: params
      end.to change(Meal, :count).by 1
    end

    it "should save the meal and ingredientswith valid params" do
      mealbook_id = create(:mealbook).id
      params = {
        "meal"=>{
          "desc"=>"### Test",
          "ingredients"=>[
            { name: "Salt", measurement_unit: "TSP", quantity: "0.5", _delete: false },
            { name: "Pepper", measurement_unit: "TSP", quantity: "1", _delete: false },
          ],
          "name"=>"Test",
          "mealbook_id" => mealbook_id
        },
      }
      expect do
        post "/meals", params: params
      end.to change(Ingredient, :count).by 2
    end
  end
end
