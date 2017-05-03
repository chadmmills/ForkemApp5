module PlannerNav

  class Default < SimpleDelegator
    include Rails.application.routes.url_helpers
    def mealbook; __getobj__; end
    def template
      "/layouts/default_nav"
    end
  end

  class DefaultNav < Default
    def home; name; end
    def home_url; mealbook; end
  end

  class MealbookPlannerNav < Default
    def home; "Mealbooks"; end
    def home_url; "/"; end
    def new_meal_url
      new_mealbook_meal_path(mealbook)
    end
    def grocery_list_url
      mealbook_grocery_list_path(
        mealbook,
        start_date: mealbook.beginning_of_week,
        end_date: mealbook.end_of_week,
      )
    end
    def template
      "/layouts/mealbook_nav"
    end
  end

  def self.for(path, mealbook)
    (planner_navs[path] || DefaultNav).new(mealbook)
  end

  def self.planner_navs
    { "mealbooks#show" => MealbookPlannerNav }
  end
end
