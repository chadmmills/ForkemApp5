class GroceryListsController < ApplicationController
  layout "meal_planner"
  def show
    mealbook = MealbookPlanner.new(mealbook: Mealbook.find(params[:mealbook_id]))
    start_date = Date.parse(params[:start_date]) rescue mealbook.beginning_of_week
    end_date = Date.parse(params[:end_date]) rescue mealbook.end_of_week

    render locals: {
      mealbook: mealbook,
      grocery_list: GroceryList.new(
        mealbook: mealbook,
        start_date: start_date,
        end_date: end_date,
      )
    }
  end

  private

  class GroceryList
    attr_reader :mealbook, :start_date, :end_date

    def initialize(mealbook:, start_date:, end_date:)
      @mealbook = mealbook
      @start_date = start_date
      @end_date = end_date
    end

    def to_json
      Ingredient.grocery_list_json_for_date_range(
        mealbook.id,
        start_date,
        end_date,
      )
    end
  end
end
