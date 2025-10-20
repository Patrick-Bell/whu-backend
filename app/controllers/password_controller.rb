class PasswordController < ApplicationController

    def handle_email
        email = params[:email]
        @manager = Manager.find_by(email: email)
      
        unless @manager
          render json: { error: 'Email not found' }, status: :not_found
          return
        end
      
        # Generate 6-digit code
        code = rand.to_s[2..7]
        @manager.update!(
          reset_password_code: code,
          reset_password_sent_at: Time.current
        )
      
        # Send email with code
        PasswordMailer.with(manager: @manager, code: code).forgot_password.deliver_later
      
        render json: { message: 'Reset code sent successfully' }
      end
      
      


    def verify_code
        email = params[:email]
        code  = params[:code]
      
        @manager = Manager.find_by(email: email)
      
        unless @manager
          render json: { error: 'Email not found' }, status: :not_found
          return
        end
      
        if @manager.reset_password_sent_at < 10.minutes.ago
            @manager.update!(reset_password_code: nil, reset_password_sent_at: nil)
          render json: { error: 'Reset token has expired' }, status: :unauthorized
          return
        end
      
        if code == @manager.reset_password_code
          render json: { message: 'Code verified' }
          return
        else
          render json: { error: 'Invalid code' }, status: :unauthorized
          return
        end
      end


      def create_password
        email = params[:email]
        new_password = params[:new_password]
        confirm_password = params[:confirm_password]
      
        @manager = Manager.find_by(email: email)
        unless @manager
          render json: { error: 'Email not found' }, status: :not_found
          return
        end
      
        unless new_password == confirm_password
          render json: { error: 'Passwords do not match' }, status: :unauthorized
          return
        end
      
        if @manager.reset_password_sent_at.nil? || @manager.reset_password_sent_at < 10.minutes.ago
          @manager.update!(reset_password_code: nil, reset_password_sent_at: nil)
          render json: { error: 'Reset token has expired' }, status: :unauthorized
          return
        end
      
        if @manager.update(password: new_password, reset_password_code: nil, reset_password_sent_at: nil)
          PasswordMailer.with(manager: @manager).create_password.deliver_later
          render json: { message: 'Password updated successfully' }
        else
          render json: { error: @manager.errors.full_messages }, status: :unauthorized
        end
      end
      
          
      
end
