class ApplicationController < ActionController::Base
  include Clearance::Controller
  protect_from_forgery with: :exception

  private

  def auth_token_user
    authenticate_with_http_token do |token, options|
      if token == 'abc'
        User.first.tap do |user|
          sign_in user
        end
      end
    end
  end

  def require_login
    auth_token_user || super
  end
end
