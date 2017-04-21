class IngredientExtractor
  def initialize(text)
    @text = text
  end

  def process
    lines.each do |line|
      parsed_ingredients.push(LineExtractor.new(line).data)
    end
  end

  def parsed_ingredients
    @_parsed_ingredients ||= []
  end
  private
  attr_reader :text

  def lines
    @_lines ||= text.split("\n").map(&:strip)
  end

  class LineExtractor
    attr_reader :text, :quantity_extractor, :measurement_extractor
    def initialize(text, quantity_extractor: QuantityExtractor, measurement_extractor: MeasurementExtractor)
      @text                   = text
      @quantity_extractor     = quantity_extractor
      @measurement_extractor  = measurement_extractor
    end

    def data
      {
        quantity: quantity.to_s,
        measurement_unit: measurement_unit.to_s,
        desc: desc,
      }
    end

    private

    def words
      @_words ||= text.split(" ").map { |w| Word.new(w) }
    end

    def quantity
      @quantity ||= quantity_extractor.extract_qty_from(words.first)
    end
    
    def measurement_unit
      @measurement_unit ||= measurement_extractor.extract_measurement_from(words)
    end

    def desc
      words.select(&:include_in_desc?).join(" ")
    end
  end

  class Word < SimpleDelegator
    attr_accessor :include_in_desc
    def initialize(word)
      super(word)
      @include_in_desc = true
    end
    def include_in_desc?
      include_in_desc
    end
  end

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
        measurement_word.include_in_desc = false
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
      (measurement_units[ unit_key ] || NullUnit).new(unit_key, words)
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
  end


  class QuantityExtractor
    class Quantity < SimpleDelegator
      def given?; true; end
    end
    class NullQuantity
      def given?; false; end
      def to_s; "1"; end
    end
    def self.extract_qty_from(quantity_string)
      if quantity_string.include?("/")
        quantity_string.include_in_desc = false
        Quantity.new(quantity_string.to_r)
      elsif quantity_string.include?(".") && quantity_string.to_f != 0.0
        quantity_string.include_in_desc = false
        Quantity.new(quantity_string.to_f)
      elsif quantity_string.to_i != 0
        quantity_string.include_in_desc = false
        Quantity.new(quantity_string.to_i)
      else
        NullQuantity.new
      end
    end
  end

end
