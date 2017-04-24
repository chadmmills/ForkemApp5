module IngredientExtractor
  class Word < SimpleDelegator
    attr_accessor :include_in_name

    def initialize(word)
      super(word)
      @include_in_name = true
    end

    alias :include_in_name? :include_in_name

  end
end
