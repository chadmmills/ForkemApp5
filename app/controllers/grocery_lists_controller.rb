class GroceryListsController < ApplicationController
  layout "meal_planner"

  def index
    respond_to do |format|
      format.json {
        render json: MealbookGroceryLists.new(mealbook).query
      }
    end
  end

  def show
    respond_to do |format|
      format.json do
        render json: {
          grocery_list: mealbook
            .grocery_lists
            .select(:id)
            .merge(GroceryList.with_name)
            .find(params[:id])
            .as_json
            .merge(
              grocery_list_items: GroceryListItemsQuery.new(params[:id]).run,
              grocery_list_items_general: []
          ),
          mealbook: mealbook
        }
      end

      format.html { render locals: {
        grocery_list: mealbook.grocery_lists.find(params[:id]),
        mealbook: mealbook
      } }
    end
  end

  def new
    data = {
      mealbook: mealbook,
      grocery_list: Ingredient.grocery_list_json_for_date_range(
        mealbook.id,
        start_date,
        end_date,
      )
    }
    respond_to do |format|
      format.json { render json: data }
      format.html { render :show, locals: { grocery_list: GroceryList.new, mealbook: mealbook } }
    end
  end

  def create
    GroceryListCreator.new(
      start_date: start_date,
      end_date: end_date,
      mealbook_id: mealbook.id,
      ingredients: Ingredient.grocery_list_json_for_date_range(
        mealbook.id,
        start_date,
        end_date,
      )
    ).run
  end


  def destroy
    GroceryList.find(params[:id]).destroy!

    respond_to do |format|
      format.json do
        render json: MealbookGroceryLists.new(mealbook).query
      end
    end
  end

  private
    def mealbook
      @_mealbook ||= MealbookPlanner.new(mealbook: Mealbook.find(params[:planner_id]))
    end

    def start_date
      Date.parse(params[:start_date]) rescue mealbook.beginning_of_week
    end

    def end_date
      Date.parse(params[:end_date]) rescue mealbook.end_of_week
    end

  class GroceryListCreator
    def initialize(start_date:, end_date:, ingredients:, mealbook_id:)
      @end_date = end_date
      @ingredients = ingredients
      @mealbook_id = mealbook_id
      @start_date = start_date
    end

    def run
      ap ingredients
      list = GroceryList.create! start_date: start_date, end_date: end_date, mealbook_id: mealbook_id
      ingredients_with_list_id = ingredients.map do |ingredient|
        {
          edited_name: ingredient["name"],
          grocery_list_id: list.id,
          ingredient_ids: ingredient["ingredient_ids"],
          meal_id: ingredient["meal_id"],
          orig_name: ingredient["name"],
        }
      end
      GroceryListItem.create! ingredients_with_list_id
    end

    private

    attr_reader :start_date, :end_date, :ingredients, :mealbook_id
  end
end
