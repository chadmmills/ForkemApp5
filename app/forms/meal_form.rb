module MealForm
  class Base < SimpleDelegator
    def to_json
      {
        name: name,
        desc: desc,
        url: form_url,
        httpMethod: http_method,
        ingredients: ingredients.map(&:as_json),
      }.to_json
    end

    def form_url; ""; end
    def http_method; ""; end
  end

  class UpdateForm < Base
    def form_url
      "/meals/#{id}"
    end

    def http_method
      "put"
    end
  end

  class NewForm < Base
    def form_url
      "/meals"
    end

    def http_method
      "post"
    end
  end
  
  def self.for(meal)
    (meal.persisted? ? UpdateForm : NewForm ).new(meal)
  end
end
