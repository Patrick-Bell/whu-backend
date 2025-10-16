# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
    include ActionController::Cookies
  

    SESSION_KEY = ENV['SESSION_KEY']

    def create
      # Find the user by email
      @user = Manager.find_by(email: params[:manager][:email])
    
      unless @user
        return render json: { error: 'Invalid email address' }, status: :unprocessable_content
      end
    
      # Authenticate password
      if @user.authenticate(params[:manager][:password])
        # Generate JWT token (1 hour expiration)
        token = JWT.encode({
          user_id: @user.id,
          email: @user.email,
          exp: 2.hours.from_now.to_i
        }, SESSION_KEY, 'HS256')
    
        # Set the token in cookies (optional for API clients)
        cookies.signed[:token] = {
          value: token,
          httponly: true,         # ok
          same_site: Rails.env.development? ? :lax : :none,
          secure: Rails.env.production? ? true : false
          expires: 2.hours.from_now,
          path: '/'
        }
    
        # Mark user online
        @user.update(online: true)
        
        # Return success response
        render json: {
          message: 'Login Successful',
          user: @user.as_json(except: [:password_digest]), # don't send password digest
          token: token,
        }, status: :ok
      else
        render json: { error: 'Invalid password' }, status: :unauthorized
      end
    end
    
      
  
    def destroy
      cookies.delete(
        :token,
        signed: true,
        httponly: true,
        path: "/",
        same_site: Rails.env.development? ? :lax : :none,
        secure: Rails.env.production? ? true : false
        )
      render json: { message: 'Logged out successfully' }, status: :ok
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

    private

    def decoded_token
      @decoded_token ||= JWT.decode(cookies.signed[:token], SESSION_KEY, true, { algorithm: 'HS256' }).first
    rescue JWT::DecodeError
      nil
    end

  end
  