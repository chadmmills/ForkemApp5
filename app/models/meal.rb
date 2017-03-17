class Meal < ApplicationRecord
  belongs_to :mealbook

  has_many :meal_assignments
  has_many :ingredients
end
