# ApplicationController serves as the base controller for all API controllers in the application.
# It inherits from ActionController::API, providing a lightweight controller suitable for API-only apps.
# The controller includes the Authenticable module to handle authentication logic across all inheriting controllers.
class ApplicationController < ActionController::API
  include Authenticable
end
