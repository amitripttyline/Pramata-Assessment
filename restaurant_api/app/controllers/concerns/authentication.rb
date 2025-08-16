module Authentication
  extend ActiveSupport::Concern

  def authenticate_request!
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    if header
      decoded = JwtService.decode(header)
      if decoded
        @current_user = User.find(decoded[:user_id])
      else
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Missing token' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Invalid token' }, status: :unauthorized
  end

  def authenticate_admin!
    authenticate_request!
    unless @current_user&.staff?
      render json: { error: 'Admin access required' }, status: :forbidden
    end
  end

  def current_user
    @current_user
  end

  def logged_in?
    !!current_user
  end
end
