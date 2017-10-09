class MealsController < ApplicationController
  layout "meal_planner"

  def show
    meal = Meal.find(params[:id])

    render locals: {
      meal: MealPresenter.new(meal: meal),
      mealbook: meal.mealbook
    }
  end

  def new
    @mealbook = Mealbook.find(params[:mealbook_id])
    render locals: { mealbook: Mealbook.find(params[:mealbook_id]) }
  end

  def create
    meal = Meal.new(meal_params)
    meal_builder = MealBuilder.new(
      meal: meal,
      ingredient_builder: IngredientBuilder.new(
        IngredientConsolidator.new(meal, ingredient_params, []).merged_ingredients
      ),
    )

    if meal_builder.save
      render json: { success: true }
    else
      render json: { success: false, error: "All the things" }
    end
  end

  def edit
    meal = Meal.find(params[:id])

    render locals: {
      meal: meal,
      mealbook: meal.mealbook,
    }
  end

  def update
    meal = Meal.find(params[:id])
    meal.update_attributes(meal_params)
    meal_builder = MealBuilder.new(
      meal: meal,
      ingredient_builder: IngredientBuilder.new(
        IngredientConsolidator.new(meal, ingredient_params, meal.ingredients).merged_ingredients
      ),
    )

    if meal_builder.save
      render json: { success: true }
    else
      render json: { success: false, error: "All the things" }
    end
  end

  private
  def meal_params
    params.require(:meal).
      permit(
        :name,
        :desc,
        :mealbook_id,
    )
  end

  def ingredient_params
    params.require(:meal).permit(
        ingredients: [
          :name,
          :measurement_unit,
          :quantity,
          :id,
          :_delete,
        ]
    ).fetch(:ingredients, [])
  end

  class MealPresenter < SimpleDelegator;
    attr_reader :parser
    def initialize(meal:, parser: Redcarpet::Markdown.new(Redcarpet::Render::HTML))
      super(meal)
      @parser = parser
    end

    def desc
      parser.render(super || "")
    end

  end

  class MealBuilder
    attr_reader :meal, :ingredient_builder
    def initialize(meal:, ingredient_builder:)
      @meal = meal
      @ingredient_builder = ingredient_builder
    end
    delegate :id, to: :meal

    def save
      if meal.save!
        ingredient_builder.save!
      end
    end
  end

  class SaveableIngredient
    attr_reader :ingredient
    def initialize(ingredient)
      @ingredient = ingredient
    end
    delegate :valid?, to: :ingredient

    def save!
      ingredient.save!
    end
  end

  class DeleteableIngredient < SaveableIngredient
    def initialize(ingredient)
      @ingredient = ingredient
    end

    def valid?
      true
    end

    def save!
      ingredient.destroy!
    end
  end

  class IngredientConsolidator
    attr_reader :meal, :form_params, :existing_ingredients
    def initialize(meal, form_params, existing_ingredients)
      @meal = meal
      @form_params, @existing_ingredients = form_params, existing_ingredients
    end

    def merged_ingredients
      form_params.map do |ing|
        (existing_ingredients.find { |e| e.id == ing[:id]} ||
          Ingredient.new(ing.merge(meal: meal))).as do |ingredient|
          ingredient.update_attributes(ing)
          ingredient_action_type_for(ingredient)
        end
      end
    end

    def ingredient_action_type_for(ingredient)
      if ingredient._delete
        DeleteableIngredient.new(ingredient)
      else
        SaveableIngredient.new(ingredient)
      end
    end

  end

  class IngredientBuilder
    attr_reader :ingredients
    attr_accessor :meal
    def initialize(ingredients)
      @ingredients = ingredients
    end

    def save!
      if ingredients.all?(&:valid?)
        ingredients.map(&:save!)
      else
        errors.push ingredients.map(&:errors)
        ap errors
      end
    end

    def errors
      @errors ||= []
    end
  end
end
