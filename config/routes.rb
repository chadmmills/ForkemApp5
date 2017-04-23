Rails.application.routes.draw do
  #############################################################################
  # Clearance
  #############################################################################
  constraints Clearance::Constraints::SignedIn.new do
    root to: "mealbooks#index", as: :signed_in_root
  end

  resources :passwords, controller: "clearance/passwords", only: [:create, :new]
  resource :session, controller: "clearance/sessions", only: [:create]

  resources :users, controller: "clearance/users", only: [:create] do
    resource :password,
      controller: "clearance/passwords",
      only: [:create, :edit, :update]
  end

  get "/login" => "clearance/sessions#new", as: "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"
  get "/create-account" => "clearance/users#new", as: "sign_up"
  #############################################################################

  resources :mealbooks do
    resources :meals, only: :new
  end
  resources :meals
  resources :meal_assignments, path: "meal-assignments"
  resources :parsed_ingredients, path: "parsed-ingredients", only: [:create]

  namespace :utilities do
    resources :markdown, only: :create
  end

  root to: "mealbooks#show"
end
