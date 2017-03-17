class MealbooksController < ApplicationController
  layout "meal_planner"

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
    MealbookPlanner.new(mealbook: Mealbook.first, current_date: weekday)
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

end
