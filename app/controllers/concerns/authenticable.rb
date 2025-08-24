# Provides authentication functionality for controllers by verifying JWT tokens
# and setting the current admin user.
#
# This concern:
# - Includes the JsonWebToken module for JWT encoding/decoding.
# - Adds a before_action to authenticate the admin before each controller action.
# - Exposes a `current_admin` reader for accessing the authenticated admin.
#
module Authenticable
  extend ActiveSupport::Concern
  include JsonWebToken

  included do
    before_action :authenticate_admin!
    attr_reader :current_admin
  end

  private

  def authenticate_admin!
    header = request.headers["Authorization"]
    token = header.split.last if header.present?
    decoded = jwt_decode(token) if token
    if decoded && (admin = Admin.find_by(id: decoded[:admin_id]))
      @current_admin = admin
    else
      render json: { error: "Not Authorized" }, status: :unauthorized
    end
  end
end
