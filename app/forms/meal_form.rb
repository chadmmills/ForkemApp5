module MealForm # :nodoc:
  class Base < SimpleDelegator
    def to_json
      {
        name: name,
        desc: desc,
        url: form_url,
        success_url: response_success_path,
        httpMethod: http_method,
        ingredients: ingredients.map(&:as_json),
      }.to_json
    end

    def form_url; ""; end
    def http_method; ""; end
    def response_success_path; "/mealbooks/#{mealbook_id}"; end
  end

  class UpdateForm < Base
    def form_url
      "/meals/#{id}"
    end

    def http_method
      'put'
    end
  end

  class NewForm < Base
    def form_url
      '/meals'
    end

    def http_method
      'post'
    end
  end

  def self.for(meal)
    (meal.persisted? ? UpdateForm : NewForm).new(meal)
  end
end
