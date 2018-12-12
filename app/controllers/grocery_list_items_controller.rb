class GroceryListItemsController < ApplicationController

  def create
    grocery_list = GroceryList.select(:id).with_name.find(params[:grocery_list_id])

    grocery_list.grocery_list_items.create! orig_name: params[:name], edited_name: params[:name]

    respond_to do |format|
      format.json do
        render json: {
          grocery_list: {
            id: grocery_list.id,
            name: grocery_list.name,
            grocery_list_items: GroceryListItemsQuery.new(grocery_list.id).run,
          }
        }
      end
    end
  end

  def update
    item = GroceryListItem.find(params[:id])
    item.update! is_completed: params[:is_completed]

    grocery_list = GroceryList.select(:id).with_name.find(item.grocery_list_id)

    respond_to do |format|
      format.json do
        render json: {
          grocery_list: {
            id: item.grocery_list_id,
            name: grocery_list.name,
            grocery_list_items: GroceryListItemsQuery.new(grocery_list.id).run,
          }
        }
      end
    end
  end

    private

end

