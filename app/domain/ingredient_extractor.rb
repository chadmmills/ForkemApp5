module IngredientExtractor
  class Base
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

    def success?
      parsed_ingredients.any?
    end

    def error_message
      'We were unable to process any ingredients :('
    end

    private
    attr_reader :text

    def lines
      @_lines ||= text.split("\n").map(&:strip)
    end

  end

  def self.for(text)
    Base.new(text)
  end

end
