class MealbookGroceryLists

  def initialize(mealbook)
    @mealbook = mealbook
  end

  def query
    mealbook
      .grocery_lists
      .select(:id)
      .order(created_at: :desc)
      .merge(GroceryList.with_name)
  end

  private

  attr_reader :mealbook
end
