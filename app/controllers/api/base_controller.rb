module Api
  class BaseController < ApplicationController
    include ActionController::HttpAuthentication::Basic::ControllerMethods # could be moved to application_controller.rb
    include ActionController::HttpAuthentication::Token::ControllerMethods
    # skip_before_action :authenticate_user!
    # skip_before_action :verify_authenticity_token
    before_action :authenticate_with_api_key

    attr_reader :current_bearer, :current_api_key

    protected

    def authenticate_with_api_key
      authenticate_or_request_with_http_token do |token, _options|
        @current_api_key = ApiKey.find_by_token(token)
        @current_bearer = current_api_key&.bearer
      end
    end

    # Override rails default 401 response to return JSON content-type
    # with request for Bearer token
    # https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html
    def request_http_token_authentication(realm = "Application", message = nil)
      json_response = { errors: [message || "Access denied"] }
      headers["WWW-Authenticate"] = %(Bearer realm="#{realm.tr('"', '')}")
      render json: json_response, status: :unauthorized
    end
  end
end
