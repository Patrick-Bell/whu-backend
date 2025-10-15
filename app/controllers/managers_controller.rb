class ManagersController < ApplicationController
    before_action :set_manager, only: %i[ show update destroy ]
  
    # GET /managers
    def index
      # Include associated games but not the picture attachment
      @managers = Manager.includes(:games).all
    
      # Render the managers with games and picture_url
      render json: @managers.as_json(include: :games)
    end
    
  
    # GET /managers/1
    # In your controller (ManagersController)
  def show
    @manager = Manager.includes(:games).find_by(id: params[:id])
    
    render json: @manager.as_json(include: :games)
  
  end
  
   # POST /managers
   
 #  def create
 #   @manager = Manager.new(manager_params)
 # 
 #   if @manager.save
 #     #if current_admin && current_admin.notifications
 #       # Send emails only if notifications are enabled
 #       #ManagerMailer.new_manager(@manager).deliver_now
 #       #ManagerMailer.new_manager_admin(@manager).deliver_now
 #    # else
 #       Rails.logger.debug "Notifications are disabled for the current admin. Emails were not sent."
 #     #end
 # 
 #     render json: @manager, status: :created, location: @manager
 #   else
 #    render json: @manager.errors, status: :unprocessable_entity
 #   #end
 # end
 # end

def create
  @manager = Manager.new(manager_params)

  if @manager.save
    render json: @manager, status: :created, location: @manager
  else
    render json: @manager.errors, status: :unprocessable_entity
  end
end
  
  def update_password
    manager = Manager.find_by(id: params[:id])
  
    if manager.nil?
      render json: { error: 'Manager not found' }, status: :not_found
      return
    end
  
    # Check if the current password matches
    if manager.authenticate(params[:currentPassword])  # Check current password
      if params[:newPassword] == params[:confirmPassword]
        manager.password = params[:newPassword]
        if manager.save
          render json: { message: 'Password updated successfully' }, status: :ok
        else
          render json: { error: 'Failed to update password' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'New password and confirmation do not match' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Incorrect current password' }, status: :unauthorized
    end
  end
  
  def update_access
    @manager = Manager.find_by(id: params[:id])
  
    if @manager
      @manager.access = params[:access]
      if @manager.save
        render json: { message: "Access updated successfully" }, status: :ok
      else
        render json: { error: @manager.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Manager not found" }, status: :not_found
    end
  end
  
  
  
  
  
    # PATCH/PUT /managers/1
    def update
      Rails.logger.debug("Manager Params: #{manager_params.inspect}")
      if @manager.update(manager_params)
        render json: @manager
      else
        render json: @manager.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /managers/1
    def destroy
      @manager.destroy!
    end
  
    def toggle_theme
      @manager = Manager.find_by(id: params[:id])
    
      if @manager.nil?
        render json: { error: "Manager not found" }, status: :not_found and return
      end
    
      @manager.mode = params[:newMode]
      if @manager.save
        render json: { message: "Mode updated successfully", mode: params{:newMode}[:theme][:newMode] }, status: :ok
      else
        render json: { error: @manager.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
  
  
  
    def toggle_notification
      @manager = Manager.find(params[:id])
      type = params[:type]
    
      case type
      when "email"
        @manager.update(notifications: params[:enabled])
      when "game"
        @manager.update(game_notifications: params[:enabled])
      when "weeky"
        @manager.update(weekly_notifications: params[:enabled])
      else
        render json: { error: "Invalid type" }, status: :unprocessable_entity and return
      end
    
      render json: { success: true, manager: @manager }, status: :ok
    end
    
  
  
  
  
  
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_manager
        @manager = Manager.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def manager_params
        params.require(:manager).permit(:name, :email, :password, :last_name)
      end
  end
  