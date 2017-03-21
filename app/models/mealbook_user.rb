class MealbookUser < ApplicationRecord
  belongs_to :mealbook
  belongs_to :user
end
