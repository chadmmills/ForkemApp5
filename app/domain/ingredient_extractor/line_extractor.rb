module IngredientExtractor
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
        name: name,
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

    def name
      words.select(&:include_in_name?).join(" ")
    end
  end
end
