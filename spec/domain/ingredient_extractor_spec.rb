require 'rails_helper'

RSpec.describe IngredientExtractor do
  describe IngredientExtractor::LineExtractor do
    it 'should spit out ingredient data map' do
      ingredient_from_line = described_class.new("3 pound pork shoulder, trimmed of excess fat")

      expect(ingredient_from_line.data).to match(
        { quantity: "3", measurement_unit: "LB", name: "pork shoulder, trimmed of excess fat" }
      )
    end
  end

  describe IngredientExtractor::MeasurementExtractor do
    it 'should return null unit if measurement not found' do
      class FakeWord
        def downcase; 'somecrazykeywedonthave'; end
      end
      null_unit = described_class.extract_measurement_from(
        [FakeWord.new]
      )

      expect(null_unit.to_s).to eq("EA")
    end
  end

  describe 'text processing' do
    it 'should split out quantity' do
      text = "3 pound pork shoulder, trimmed of excess fat
              1/2 cup sliced red onion
              2 (14.5 oz) cans diced tomatoes
              pinch of salt and pepper"
      extractor = described_class.for(text)

      extractor.process

      expect(extractor.parsed_ingredients.first[:quantity]).to eq "3"
      expect(extractor.parsed_ingredients.second[:quantity]).to eq "1/2"
      expect(extractor.parsed_ingredients.last[:quantity]).to eq "1"
    end

    it 'should split out measurement units' do
      text = "3 pound pork shoulder, trimmed of excess fat
              1/2 cup sliced red onion
              2 (14.5 oz) cans diced tomatoes
              16 oz beef stock
              pinch of salt and pepper"
      extractor = described_class.for(text)

      extractor.process

      expect(extractor.parsed_ingredients.first).to match(
        { quantity: "3", measurement_unit: "LB", name: "pork shoulder, trimmed of excess fat" }
      )
      expect(extractor.parsed_ingredients.third).to match(
        { quantity: "2", measurement_unit: "EA", name: "(14.5 oz) cans diced tomatoes" }
      )
      expect(extractor.parsed_ingredients.fourth).to match(
        { quantity: "16", measurement_unit: "OZ", name: "beef stock" }
      )
      expect(extractor.parsed_ingredients.last).to match(
        { quantity: "1", measurement_unit: "EA", name: "pinch of salt and pepper" }
      )
    end
  end
end
