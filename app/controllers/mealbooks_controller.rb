class MealbooksController < ApplicationController
  def show
    respond_to do |format|
      format.html do
        render locals: { mealbook: mealbook }
      end
      format.json do
        render json: { mealbook: mealbook }
      end
    end
  end

  private

  def mealbook
    return MealbookPlanner.new(current_date: weekday)
  end

  def weekday
    @_weekday ||= Date.parse(params[:weekdate]) rescue Date.today
  end

  def weekdays
    (weekday.beginning_of_week..weekday.end_of_week).map do |dateObj|
      OpenStruct.new(
        title: dateObj.strftime("%A"),
        date: dateObj.to_s,
        meal: { id: 123 }
      )
    end
  end

  class MealbookPlanner
    attr_reader :current_date
    def initialize(current_date: Date.today)
      @current_date = current_date
    end

    def as_json(args)
      {
        name: name,
        current_date: current_date,
        current_date_short: current_date_short,
        prev_week: current_date - 1.week,
        next_week: current_date + 1.week,
        meals: meals.map(&:as_json),
        weekdays: weekdays,
      }
    end

    def current_date_short
      current_date.strftime("%b-%d")
    end

    def name; "Mills Planner"; end

    def beginning_of_week
      current_date.beginning_of_week
    end

    def end_of_week
      current_date.end_of_week
    end

    def meals
      [
        MealbookMeal.new
      ]
    end

    def weekdays
      (beginning_of_week..end_of_week).map do |dateObj|
        OpenStruct.new(
          title: dateObj.strftime("%A"),
          date: dateObj.to_s,
          meal: { id: 123 }
        )
      end
    end

    class MealbookMeal
      def as_json
        {
          title: "meal title",
        }
      end

    end
  end
end
