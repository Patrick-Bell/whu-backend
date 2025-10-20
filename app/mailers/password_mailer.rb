# app/mailers/password_mailer.rb
class PasswordMailer < ApplicationMailer
  
    def forgot_password
      @manager = params[:manager]
      @code = params[:code]
      mail(to: @manager.email, subject: 'Your password reset code')
    end

    def create_password
      @manager = params[:manager]
      mail(to: @manager.email, subject: 'Your password has been changed')
    end


  end
  