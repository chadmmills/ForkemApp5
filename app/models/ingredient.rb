class Ingredient < ApplicationRecord
  belongs_to :meal
  validates :name, presence: true
end
