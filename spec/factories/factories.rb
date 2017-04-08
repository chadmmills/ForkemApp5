FactoryGirl.define do
  factory :mealbook do
    sequence(:name) { |i| "Mealbook Name #{i}" }
    param { name.parameterize }
  end

  factory :meal do
    sequence(:name) { |i| "Meal Name #{i}" }
    desc "### Cool Title"
    mealbook
  end

  factory :ingredient do
    name "Ingredient name"
    measurement_unit "EA"
    quantity "3"
    meal
  end
end
