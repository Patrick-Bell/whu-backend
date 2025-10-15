class GameMailer < ApplicationMailer

    def complete_game
        @game = params[:game]
        mail(to: @game.manager.email, subject: "New Game Completed")
      end


end
