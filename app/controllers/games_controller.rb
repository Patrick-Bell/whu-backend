class GamesController < ApplicationController
    before_action :set_game, only: [:show]  # This callback can be kept if you need a show action
    before_action :authorize_admin, only: [:destroy]

    
    def index
      year = params[:year].to_i
    
      if year == 0
        # If 'All' is selected (i.e., year == 0), return all games
        @games = Game.includes(carts: :workers).all
      elsif year
        # Filter games released in the specified year
        @games = Game.includes(carts: :workers).where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
      else
        # Default case: return all games if no year is provided
        @games = Game.includes(carts: :workers).all
      end
    
      # Render the games, including carts with workers and manager data
      render json: @games, include: { carts: { include: :workers }, manager: {} }
    end


    def get_current_month_games
      date = Date.current
      beginning = date.beginning_of_month
      the_end = date.end_of_month
    
      @games = Game.where(date: beginning..the_end).includes(carts: :cart_workers)
    
      if @games.any?
        render json: @games, include: { carts: { include: :cart_workers } }, status: :ok
      else
        render json: { message: "No games found for this month" }, status: :not_found
      end
    end
    
    def get_previous_month_games
      date = Date.current
      beginning = date.prev_month.beginning_of_month
      the_end = date.prev_month.end_of_month
    
      @games = Game.where(date: beginning..the_end).includes(carts: :cart_workers)
    
      if @games.any?
        render json: @games, include: { carts: { include: :cart_workers } }, status: :ok
      else
        render json: { message: "No games found for previous month" }, status: :not_found
      end
    end
    
    
    
    
    
        

    def create
      @game = Game.new(game_params)
  
      if @game.save
        render json: @game, status: :created, location: @game
      else
        render json: @game.errors, status: :unprocessable_entity
      end
    end


  def completed_game
    @game = Game.find(params[:id])
    Rails.logger.info "Game ID: #{@game.id}"  # Log the game ID being processed

    if @game
      @game.update(complete_status: true)
      GameMailer.with(game: @game).complete_game.deliver_now
      render json: { message: 'Game marked as completed' }, status: :ok
    else
      render json: { error: 'Game not found' }, status: :not_found
  end
end
    
def show
render json: @game, include: {
  carts: {
    include: {
      cart_workers: { include: :worker }
    }
  },
  manager: {}
}
end



    def destroy
      @game = Game.find(params[:id])

      @game.destroy!
    end
    
    private
    
    def set_game
      @game = Game.find(params[:id])
    end

    def game_params
      params.require(:game).permit(:name, :date, :manager_id, :fixture_id)
    end


  end
  