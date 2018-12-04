class GroceryList < ApplicationRecord
  scope :with_name, -> {
    select("concat(to_char(start_date, 'Mon-DD'), ' - ', to_char(end_date, 'Mon-DD')) as name")
  }

  belongs_to :mealbook
  has_many :grocery_list_items
end
