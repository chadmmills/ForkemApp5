module ApplicationHelper
  def controller_action
    "#{params[:controller]}##{params[:action]}"
  end
end
