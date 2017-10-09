class PlannersController < ApplicationController
  before_action :require_login

  def index
    render json: { mealbook: mealbook }
  end

  def show
    respond_to do |format|
      format.html do

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
  helper_method :mealbook

  def weekday
    @_weekday ||= Date.parse(params[:weekdate]) rescue Date.today.beginning_of_week
  end

end
