class IngredientExtractor
  def initialize(text)
    @text = text
  end

  def process
    ingredient_data.each do |line|
      quantity = QuantityExtractor.for(line.first)
      measurement_unit = nil

      if quantity.given?
        non_quantity_units = line[1..line.length]
      else
        non_quantity_units = line
      end
      non_quantity_units.each do |text|
        if measurement_unit = MeasurementUnit.find_abbr(text)
          non_quantity_units.delete(text) unless text == "cans" || text == "pinch"
          break
        end
      end
      desc = non_quantity_units.join(" ")

      ingredients.push(
        {
          quantity: quantity.to_s,
          measurement_unit: measurement_unit,
          desc: desc 
        }
      )
    end
  end

  def ingredients
    @_ingredients ||= []
  end

  private
  attr_reader :text

  def lines
    @_lines ||= text.split("\n").map(&:strip)
  end

  def ingredient_data
    @_units ||= lines.map { |line| line.split(" ") }
  end


  class QuantityExtractor
    class Quantity < SimpleDelegator
      def given?; true; end
    end
    class NullQuantity
      def given?; false; end
      def to_s; "1"; end
    end
    def self.for(quantity_string)
      if quantity_string.include?("/")
        Quantity.new(quantity_string.to_r)
      elsif quantity_string.include?(".") && quantity_string.to_f != 0.0
        Quantity.new(quantity_string.to_f)
      elsif quantity_string.to_i != 0
        Quantity.new(quantity_string.to_i)
      else
        NullQuantity.new
      end
    end
  end

  module MeasurementUnit
    def self.find_abbr(unit_label_or_key)
      measurement_units[unit_label_or_key]
    end

    def self.measurement_units
      {
        "pound"     => "LB",
        "lb"        => "LB",
        "lbs"       => "LB",
        "cup"       => "CUP",
        "tsp"       => "TSP",
        "teaspoon"  => "TSP",
        "teaspoons" => "TSP",
        "can"       => "EA",
        "cans"      => "EA",
        "pinch"     => "EA",
        "oz"        => "OZ",
        "ounces"    => "OZ",
      }
    end
  end
end
