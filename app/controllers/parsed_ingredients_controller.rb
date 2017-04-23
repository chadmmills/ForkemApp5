class ParsedIngredientsController < ApplicationController
  def create
    parser = IngredientExtractor.new(params[:text])
    parser.process

    if parser.success?
      render json: { ingredients: parser.parsed_ingredients }
    else
      render json: { error: parser.error_message }
    end
  end
end
