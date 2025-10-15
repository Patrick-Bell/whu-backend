
class ApplicationController < ActionController::API
  
  include ActionController::Cookies  # <-- add this
    SESSION_KEY = ENV['SESSION_KEY']

    def authenticate_user
      unless current_user
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  
    def render_unauthorized(message)
      render json: { error: message }, status: :unauthorized
    end
  
  
  def authorize_admin
    unless @current_user&.role == 'admin'
      render json: { error: 'You do not have access to this' }, status: :unauthorized
    end
  end
  
  
  
  
  def current_user
    return @current_user if defined?(@current_user)
  
    token = cookies.signed[:token]
    return nil unless token
  
    begin
      decoded_token = JWT.decode(token, SESSION_KEY, true, { algorithm: 'HS256' })
      user_id = decoded_token[0]['user_id']
      exp = decoded_token[0]['exp']
  
      # Expired token? Delete cookie
      if Time.at(exp) < Time.now
        cookies.delete(:token, signed: true, httponly: true, path: "/", same_site: :lax, secure: false)
        return nil
      end
  
      @current_user = Manager.find_by(id: user_id)
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      nil
    end
  end

  # app/controllers/application_controller.rb
def get_current_user
  token = cookies.signed[:token]
  return render json: { user: nil } unless token

  begin
    decoded_token = JWT.decode(token, SESSION_KEY, true, { algorithm: 'HS256' })
    user_id = decoded_token[0]['user_id']
    exp = decoded_token[0]['exp']

    # Expired?
    if Time.at(exp) < Time.now
      cookies.delete(:token, signed: true, httponly: true, path: "/", same_site: :lax, secure: false)
      return render json: { user: nil }
    end

    user = Manager.find_by(id: user_id)
    if user
      render json: { user: user.as_json(except: [:password_digest]) }
    else
      render json: { user: nil }
    end
  rescue JWT::DecodeError
    render json: { user: nil }
  end
end

  
  
  
  def current_admin
    token = cookies.signed[:token]
    Rails.logger.info "Token from cookies: #{token}"  # Check if the token exists
  
    return nil unless token
  
    begin
      decoded_token = JWT.decode(token, SESSION_KEY, true, { algorithm: 'HS256' })
      Rails.logger.info "Decoded Token: #{decoded_token}"  # Check if the token is decoded properly
  
      user_id = decoded_token[0]['user_id']
      Rails.logger.info "User ID from decoded token: #{user_id}"  # Check user ID from token
      exp = decoded_token[0]['exp']
      Rails.logger.info "Token expiration time: #{exp}"  # Check expiration time
  
      # Check if the token is expired
      if Time.at(exp) < Time.now
        Rails.logger.error "JWT Token has expired"
        return nil
      end
  
      # Find the manager based on user_id
      @current_admin ||= Manager.find_by(id: user_id)
      Rails.logger.info "Current Admin: #{@current_admin.inspect}"  # Check the admin object
  
      return @current_admin
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"  # Log the error message if decoding fails
      return nil
    end
  end
  
  def set_current_admin
    @current_admin = current_admin  # Ensure it's stored in @current_admin
  end
  
  
  
  end
  