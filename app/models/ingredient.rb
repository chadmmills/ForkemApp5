class Ingredient < ApplicationRecord
  attribute :_delete, :boolean

  belongs_to :meal

  validates :name, presence: true
end
