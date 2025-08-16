class Api::AuthController < ApplicationController
  before_action :authenticate_request!, only: [:current_user, :logout]

  def register
    @user = User.new(user_params)
    
    if @user.save
      token = JwtService.encode({ user_id: @user.id })
      render json: {
        user: user_response(@user),
        token: token
      }, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(email: params[:email]&.downcase)
    
    if @user&.authenticate(params[:password])
      token = JwtService.encode({ user_id: @user.id })
      render json: {
        user: user_response(@user),
        token: token
      }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def current_user
    render json: { user: user_response(current_user) }
  end

  def logout
    # For JWT, logout is handled on the client side by removing the token
    render json: { message: 'Logged out successfully' }
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.created_at
    }
  end
end
