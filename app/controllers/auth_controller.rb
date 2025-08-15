class AuthController < ApplicationController
  skip_before_action :authenticate_admin!, only: :login

  # POST /auth/login
  def login
    admin = Admin.find_by(email: params[:email])
    if admin&.authenticate(params[:password])
      token = jwt_encode(admin_id: admin.id)
      render json: { token: token, admin: { id: admin.id, name: admin.name, email: admin.email } }, status: :ok
    else
      render json: { error: "invalid email or password" }, status: :unauthorized
    end
  end
end
