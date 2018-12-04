class GroceryListItemsController < ApplicationController

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

