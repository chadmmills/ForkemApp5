class MealbookPlanner
  WEEK_START_DAY = :sunday

  attr_reader :current_date, :current_week_date, :mealbook, :prev_week

  def initialize(mealbook:, current_week_date: Date.today, current_date: Date.today)
    @mealbook = mealbook
    @current_date = current_date
    @current_week_date = current_week_date.beginning_of_week(start_day = WEEK_START_DAY)
  end

  delegate :id, :to_param, :grocery_lists, to: :mealbook

  def as_json(args)
    {
      id: mealbook.id,
      name: name,
      current_date: current_week_date,
      current_date_short: current_date_short,
      prev_week: prev_week,
      next_week: current_week_date + 1.week,
      meals: meals.map(&:as_json),
      weekdays: weekdays,
    }
  end

  def current_date_short
    current_week_date.strftime("%b-%d")
  end

  def name
    mealbook.name
  end

  def beginning_of_week
    current_week_date.beginning_of_week(start_day = WEEK_START_DAY)
  end

  def end_of_week
    current_week_date.end_of_week(start_day = WEEK_START_DAY)
  end

  def prev_week
    current_week_date - 1.week
  end

  def meals
    mealbook.meals.select(:id, :name)
    # [
    #   { id: 'asldkfj', name: 'First' },
    #   { id: 'qweaslfj', name: 'Last' },
    # ]
  end

  def assigned_meals
    @_assigned_meals ||= mealbook.meals_assigned_within_range(week_range)
  end

  def week_range
    (beginning_of_week..end_of_week)
  end

  def weekdays
    week_range.map do |dateObj|
      current_day_meals = assigned_meals.select { |m| m.assigned_on == dateObj }
      meals_by_meal_type = [ 0, 1, 2 ].map do |day_position|
        current_day_meals.detect { |meal| meal.position == day_position } || MealType.for(day_position)
      end
      Weekday.new(
        dateObj.strftime("%A"),
        dateObj.to_s,
        meals_by_meal_type,
      )
    end
  end

  Weekday = Struct.new(:title, :date, :meals)

  class MealType
    TYPES = [
      "Breakfast",
      "Lunch",
      "Dinner",
    ]

    def self.for(position)
      { mealType: TYPES[position] }
    end
  end


end
