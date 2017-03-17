FactoryGirl.define do
  factory :mealbook do
    sequence(:name) { |i| "Meal Name #{i}" }
    param { name.parameterize }
  end
end
