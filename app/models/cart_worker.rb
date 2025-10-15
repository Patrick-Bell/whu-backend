class CartWorker < ApplicationRecord
    belongs_to :cart
    belongs_to :worker
  
    # Using before_save callback correctly
    before_save :calculate_hours
    before_save :calculate_late_or_early
  
    def calculate_hours
      # Ensure the times are in the correct format before calculating the difference
      start_time = self.start_time # Use 'self' to reference model attributes
      finish_time = self.finish_time
  
      # Parse the time strings into Time objects (assuming they are strings and not DateTime objects)
      start_time = Time.parse(start_time) if start_time.is_a?(String)
      finish_time = Time.parse(finish_time) if finish_time.is_a?(String)
  
      # Calculate the difference in seconds
      time_difference = finish_time - start_time
  
      # Convert the time difference from seconds to hours
      hours = (time_difference / 3600).round(2)  # 1 hour = 3600 seconds
  
      # You can store the calculated hours in a model attribute or just return it
      self.hours = hours
    end
  
    def calculate_late_or_early
      kick_off = self.kick_off.in_time_zone  # this uses 'London' because of config
      start_time = self.start_time.strftime("%H:%M")  # convert to string in HH:MM format
    
      # Combine the date from kick_off and start_time as a London time
      start_time_on_day = Time.zone.parse("#{kick_off.to_date} #{start_time}")
    
      # Expected start time is 3 hours before kick-off
      actual_start_time = kick_off - 3.hours
    
      difference_in_minutes = ((start_time_on_day - actual_start_time) / 60).round
    
      if difference_in_minutes < 0
        self.time_message = "Early by #{difference_in_minutes.abs} minutes"
      elsif difference_in_minutes > 0
        self.time_message = "Late by #{difference_in_minutes} minutes"
      else
        self.time_message = "On Time"
      end
    end
    
    
    
  
  
  end
  