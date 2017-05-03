class MealbookPlanner
  WEEK_START_DAY = :sunday

  attr_reader :current_date, :mealbook

  def initialize(mealbook:, current_date: Date.today)
    @mealbook = mealbook
    @current_date = current_date
  end

  delegate :to_param,
    :to_model,
    :id,
    to: :mealbook

  def as_json(args)
    {
      id: mealbook.id,
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

  def name
    mealbook.name
  end

  def beginning_of_week
    current_date.beginning_of_week(start_day = WEEK_START_DAY)
  end

  def end_of_week
    current_date.end_of_week(start_day = WEEK_START_DAY)
  end

  def meals
    mealbook.meals.select(:id, :name)
  end

  def assigned_meals
    @_assigned_meals ||= mealbook.meals_assigned_within_range(week_range)
  end

  def week_range
    (beginning_of_week..end_of_week)
  end

  def weekdays
    week_range.map do |dateObj|
      OpenStruct.new(
        title: dateObj.strftime("%A"),
        date: dateObj.to_s,
        meals: assigned_meals.select { |m| m.assigned_on == dateObj }
      )
    end
  end

end
