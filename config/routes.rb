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

  resources :planners do
    resources :grocery_lists, only: [:create, :new, :show], path: "grocery-lists"
  end
  resources :mealbooks do
    resources :meals, only: :new
  end

  scope '/api' do
    defaults format: :json do
      resources :mealbooks, only: :index
      resources :grocery_list_items, path: "grocery-list-items"
      resources :meal_assignments, path: "meal-assignments"
      resources :planners do
        resources :grocery_lists, only: [:index, :new, :show, :destroy], path: "grocery-lists"
      end
    end
  end
  resources :meals
  resources :meal_assignments, path: "meal-assignments"
  resources :parsed_ingredients, path: "parsed-ingredients", only: [:create]

  namespace :utilities do
    resources :markdown, only: :create
  end

  root to: "mealbooks#show"
end
