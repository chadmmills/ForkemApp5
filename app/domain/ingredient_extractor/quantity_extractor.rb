module IngredientExtractor
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
        quantity_string.include_in_name = false
        Quantity.new(quantity_string.to_r)
      elsif quantity_string.include?(".") && quantity_string.to_f != 0.0
        quantity_string.include_in_name = false
        Quantity.new(quantity_string.to_f)
      elsif quantity_string.to_i != 0
        quantity_string.include_in_name = false
        Quantity.new(quantity_string.to_i)
      else
        NullQuantity.new
      end
    end
  end
end
