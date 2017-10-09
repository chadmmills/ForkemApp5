class MealAssigner
  class InvalidError < StandardError; end
  def initialize(mealbook_assignment:, position:, assignment_date:, assignment_klass: MealAssignment)
    @mealbook_assignment  = mealbook_assignment
    @position             = position
    @assignment_date      = assignment_date
    @assignment_klass     = assignment_klass
  end

  def save
    if valid?
      assignment_klass.create(meal_id: mealbook_assignment.meal_id,
                              position: position,
                              assigned_on: assignment_date)
    end
  end

  private
  attr_reader :mealbook_assignment, :position, :assignment_date, :assignment_klass

  def valid?
    mealbook_assignment.meal_assignments_for_day(assignment_date).length < 3
  end
end

