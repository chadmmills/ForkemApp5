Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :mealbooks do
    resources :meals, only: :new
  end
  resources :meals
  resources :meal_assignments, path: "meal-assignments"

  namespace :utilities do
    resources :markdown, only: :create
  end

  root to: "mealbooks#show"
end
