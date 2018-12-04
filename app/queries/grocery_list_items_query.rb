class GroceryListItemsQuery
  def initialize(list_id)
    @list_id = list_id
  end

  def run(grocery_list_klass: GroceryListItem)
    grocery_list_klass
      .select(:id, :edited_name, :is_completed)
      .where(grocery_list_id: list_id)
      .order(:id)
  end
  
  private

  attr_reader :list_id
end
