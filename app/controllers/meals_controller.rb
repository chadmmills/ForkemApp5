class MealsController < ApplicationController
  layout "meal_planner"

  def show
    render locals: { meal: MealPresenter.new(meal: Meal.find(params[:id])) }
  end

  def new
    render locals: { mealbook: Mealbook.first }
  end

  def create
    meal_builder = MealBuilder.new(
      params: meal_params,
      ingredient_builder: IngredientBuilder
    )

    if meal_builder.save
      render json: { success: true }
    else
      render json: { success: false, error: "All the things" }
    end
  end

  def edit
    render locals: {
      meal: Meal.find(params[:id]),
      mealbook: Mealbook.first,
    }
  end

  private
  def meal_params
    params.require(:meal).
      permit(
        :name,
        :desc,
        :mealbook_id,
        ingredients: [
          :name,
          :measurement_unit,
          :quantity,
          :id,
        ]
    )
  end

  class MealPresenter < SimpleDelegator;
    attr_reader :parser
    def initialize(meal:, parser: Redcarpet::Markdown.new(Redcarpet::Render::HTML))
      super(meal)
      @parser = parser
    end

    def desc
      parser.render(super)
    end

  end

  class MealBuilder
    attr_reader :params, :meal_klass, :ingredient_builder
    def initialize(params:, ingredient_builder:, meal_klass: Meal)
      @params             = params
      @ingredient_builder = ingredient_builder
      @meal_klass         = meal_klass
    end
    delegate :id, to: :meal

    def save
      meal.save!
      ingredient_builder.new(params[:ingredients], self).save
    end

    private
    def meal
      @_meal ||= meal_klass.new(name: params[:name],
                                desc: params[:desc],
                                mealbook_id: params[:mealbook_id])
    end
  end

  class IngredientBuilder
    attr_reader :ingredients_hash, :meal
    def initialize(ingredients_hash, meal)
      @meal = meal
      @ingredients_hash = ingredients_hash || []
    end

    def save
      if ingredients.all?(&:valid?)
        ingredients.map(&:save!)
      else
        errors.push ingredients.map(&:errors)
        ap errors
      end
    end

    def ingredients
      @_ingredients ||= ingredients_hash.map { |ing| Ingredient.new(ing.merge(meal_id: meal.id)) }
    end

    def errors
      @errors ||= []
    end
    private
  end
end
