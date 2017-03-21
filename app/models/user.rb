class User < ApplicationRecord
  include Clearance::User

  has_many :mealbook_users
  has_many :mealbooks, through: :mealbook_users
end
