class ManagerMailer < ApplicationMailer

    def welcome_manager(manager)
        @manager = manager
        @email = manager.email
        mail(to: @email, subject: `Welcome, #{@manager.name}`)
      end


end
