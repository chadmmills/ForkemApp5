module IngredientExtractor
  class MeasurementExtractor
    class Base
      attr_reader :words
      def initialize(measurement_word, words)
        @words = words
      end
    end

    class NonDescriptiveUnit < Base
      def initialize(measurement_word, words)
        super(measurement_word, words)
        measurement_word.include_in_name = false
      end
    end

    class LBUnit < NonDescriptiveUnit; def to_s; "LB"; end; end
    class CupUnit < NonDescriptiveUnit; def to_s; "Cup"; end; end
    class TSPUnit < NonDescriptiveUnit; def to_s; "TSP"; end; end
    class EAUnit < Base; def to_s; "EA"; end; end
    class OZUnit < NonDescriptiveUnit; def to_s; "OZ"; end; end

    def self.extract_measurement_from(words)
      unit_key = words.detect do |word|
        measurement_units.has_key?(word.downcase)
      end
      (measurement_units[ unit_key ] || EAUnit).new(unit_key, words)
    end

    def self.measurement_units
      {
        "pound"     => LBUnit,
        "lb"        => LBUnit,
        "lbs"       => LBUnit,
        "cup"       => CupUnit,
        "tsp"       => TSPUnit,
        "teaspoon"  => TSPUnit,
        "teaspoons" => TSPUnit,
        "can"       => EAUnit,
        "cans"      => EAUnit,
        "pinch"     => EAUnit,
        "oz"        => OZUnit,
        "ounces"    => OZUnit,
      }
    end

    def self.measurement_unit_options
      measurement_units.values.compact.map(&:new).map(&:to_s)
    end
  end
end
