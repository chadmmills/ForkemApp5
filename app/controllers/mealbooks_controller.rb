class MealbooksController < ApplicationController
  before_action :require_login
  layout "meal_planner", except: %i(index create)

  def index
    render locals: { mealbooks: current_user.mealbooks }
  end

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

  def create
    new_meal_book = MealbookCreator.new(
      params: mealbook_params,
      users: [current_user]
    )
    if new_meal_book.save
      redirect_to new_meal_book
    else
      render :index, locals: { mealbooks: current_user_mealbooks }
    end
  end

  private

  def current_user_mealbooks
    []
  end

  def mealbook
    MealbookPlanner.new(mealbook: Mealbook.find(params[:id]), current_date: weekday)
  end

  def mealbook_params
    params.require(:mealbook).permit(:name)
  end

  def weekday
    @_weekday ||= Date.parse(params[:weekdate]) rescue Date.today.beginning_of_week
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

  class MealbookCreator
    attr_reader :mealbook_params, :users
    def initialize(params:, users:)
      @mealbook_params = params
      @users = users
    end
    delegate :to_model, to: :mealbook

    def save
      Mealbook.transaction do
        mealbook.save!
        mealbook.users << users
      end
    end

    private

    def mealbook
      @_mealbook ||= Mealbook.new(mealbook_params)
    end
  end

end
