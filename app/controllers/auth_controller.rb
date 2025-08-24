# AuthController handles authentication for admin users.
#
# Actions:
# - login: Authenticates an admin using email and password, and returns a JWT token on success.
#
# Filters:
# - Skips :authenticate_admin! before_action for the :login action.
class AuthController < ApplicationController
  skip_before_action :authenticate_admin!, only: :login

  # POST /auth/login
  def login
    admin = Admin.find_by(email: params[:email])
    if admin&.authenticate(params[:password])
      admin_id = admin.id

      token = jwt_encode(admin_id: admin_id)
      render json: { token: token, admin: { id: admin_id, name: admin.name, email: admin.email } }, status: :ok
    else
      render json: { error: "invalid email or password" }, status: :unauthorized
    end
  end
end
