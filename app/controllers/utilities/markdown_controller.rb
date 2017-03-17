class Utilities::MarkdownController < ApplicationController

  def create
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    render json: {
      html: markdown.render(params[:text])
    }
  end
end
