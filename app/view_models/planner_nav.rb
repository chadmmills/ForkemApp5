module PlannerNav

  class Default < SimpleDelegator
    include Rails.application.routes.url_helpers
    def mealbook; __getobj__; end
  end

  class DefaultNav < Default
    def left_link?; true; end
    def left_link_name; name; end
    def left_link_url; mealbook; end
    def right_link?; true; end
    def right_link_url
      new_mealbook_meal_path(mealbook)
    end
  end

  class MealbookPlannerNav < Default
    def left_link?; true; end
    def left_link_name; "Mealbooks"; end
    def left_link_url; "/"; end
    def right_link?; true; end
    def right_link_url
      new_mealbook_meal_path(mealbook)
    end
  end

  def self.for(path, mealbook)
    (planner_navs[path] || DefaultNav).new(mealbook)
  end

  def self.planner_navs
    { "mealbooks#show" => MealbookPlannerNav }
  end
end
