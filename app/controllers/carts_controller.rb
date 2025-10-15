class CartsController < ApplicationController
    before_action :set_cart, only: %i[show update destroy]
  
    # GET /carts
    def index
      @carts = Cart.includes(:game).all
      render json: @carts.as_json(include: :game)
    end
  
    # GET /carts/1
    def show
      @cart = Cart.includes(:workers, :game).find(params[:id])  # Preload workers and game
      render json: @cart, include: [:workers, :game]  # Include both workers and game in the response
    end
  
    # POST /carts
    def create
      cart_data = cart_params  # Access the nested cart data directly
    
      # Create a new cart from the permitted data
      cart = Cart.new(cart_data.except(:worker_ids, :worker_data))  # Exclude worker-related data for the Cart creation
  
      @fixture = Fixture.find_by(id: cart_data[:fixture_id])
      @fixture_date = @fixture[:date]
      
      if cart.save
        worker_ids = cart_data[:worker_ids]  # Extract worker_ids from the cart data
        worker_data = cart_data[:worker_data]  # Extract worker_data from the cart data
    
        
        # Create the cart_workers associations with worker_data
        worker_data.each_with_index do |worker, index|
          CartWorker.create(
            cart_id: cart.id, 
            worker_id: worker[:worker_id],
            start_time: worker[:start_time],
            finish_time: worker[:finish_time],
            half_time: worker[:half_time],
            kick_off: @fixture_date
          )
        end

        cart_with_workers = cart.as_json(
          include: {
            cart_workers: {
              include: :worker  # This includes the worker associated with each cart_worker
            }
          }
        )
        
    
        render json: { cart: cart_with_workers }, status: :created
      else
        render json: { errors: cart.errors.full_messages }, status: :unprocessable_entity
      end
  end
  
    
    
    # PATCH/PUT /carts/1
    def update
      @cart = Cart.find(params[:id])
      if @cart.update(cart_params)

        cart_workers = cart_with_workers = @cart.as_json(
          include: {
            cart_workers: {
              include: :worker  # This includes the worker associated with each cart_worker
            }
          }
        )

        render json: cart_workers
      else
        render json: @cart.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /carts/1
    def destroy
      @cart.destroy!
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_cart
        @cart = Cart.find(params[:id])
      end
      
      # Only allow a list of trusted parameters through.
      def cart_params
        params.require(:cart).permit(
          :cart_number, :quantities_start, :quantities_added, :quantities_minus, 
          :final_returns, :game_id, :float, :worker_total, :date, :fixture_id,
          worker_data: [:worker_id, :start_time, :finish_time, :half_time, :kick_off]
        )
      end
      
      
  end
  