require 'rails_helper'

RSpec.describe "Meals" do
  describe "creating a meal" do
    it "should save the meal with valid params" do
      mealbook_id = create(:mealbook).id
      params = {
        'meal' => {
          'name' => 'Updated Name',
          'desc' => '### Test',
          'mealbook_id' => mealbook_id,
          'ingredients' => [],
        },
      }
      expect do
        post "/meals", params: params
      end.to change(Meal, :count).by 1
    end

    it "should save the meal and ingredientswith valid params" do
      mealbook_id = create(:mealbook).id
      params = {
        'meal' => {
          'name' => 'Updated Name',
          'desc' => '### Test',
          'mealbook_id' => mealbook_id,
          'ingredients' => [
            { name: 'Salt', measurement_unit: 'TSP', quantity: '0.5', _delete: false },
            { name: 'Pepper', measurement_unit: 'TSP', quantity: '1', _delete: false },
          ],
        },
      }
      expect do
        post '/meals', params: params
      end.to change(Ingredient, :count).by 2
    end
  end

  describe 'updating a meal' do
    it "should update a meal without ingredients" do
      mealbook_id = create(:mealbook).id
      meal = create(:meal, mealbook_id: mealbook_id)
      params = {
        'meal' => {
          'name' => 'Updated Name',
          'desc' => '### Test',
          'mealbook_id' => mealbook_id
        },
      }

      patch "/meals/#{meal.id}", params: params
      meal.reload
      expect(meal.name).to eq('Updated Name')
    end

    it "should update a meal with ingredients" do
      mealbook_id = create(:mealbook).id
      meal = create(:meal, mealbook_id: mealbook_id)
      ingredient = create(:ingredient, meal: meal)
      params = {
        'meal' => {
          'name' => 'Updated Name',
          'desc' => '### Test',
          'ingredients' => [
            { id: ingredient.id, name: 'New Name', _delete: false },
          ],
          'mealbook_id' => mealbook_id
        },
      }

      patch "/meals/#{meal.id}", params: params
      ingredient.reload

      expect(ingredient.name).to eq('New Name')
    end

    it "should remove any ingredients if marked for deletion" do
      mealbook_id = create(:mealbook).id
      meal = create(:meal, mealbook_id: mealbook_id)
      ingredient = create(:ingredient, meal: meal)
      params = {
        'meal' => {
          'name' => 'Updated Name',
          'desc' => '### Test',
          'ingredients' => [
            { id: ingredient.id, name: 'New Name', _delete: true },
          ],
          'mealbook_id' => mealbook_id
        },
      }

      expect do
        patch "/meals/#{meal.id}", params: params
      end.to change(Ingredient, :count).from(1).to(0)
    end
  end
end
