class FixturesController < ApplicationController
    before_action :set_fixture, only: %i[ show update destroy ]
  
    # GET /fixtures
    def index
      @fixtures = Fixture.all
  
      @sorted_fixtures = @fixtures.sort_by(&:date)
  
      render json: @sorted_fixtures
    end
  
    # GET /fixtures/1
    def show
      render json: @fixture
    end
  
    # POST /fixtures
    def create
      @fixture = Fixture.new(fixture_params)
  
      if @fixture.save
        render json: @fixture, status: :created, location: @fixture
      else
        render json: @fixture.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /fixtures/1
    def update
      if @fixture.update(fixture_params)
        render json: @fixture
      else
        render json: @fixture.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /fixtures/1
    def destroy
      @fixture.destroy!
    end
  
    def get_next_3_games
      # Retrieve all fixtures
      @fixtures = Fixture.all
      
      # Get the current time
      today = Time.now
      
      # Filter for games in the future
      future_games = @fixtures.filter { |game| game.date > today }
      
      # Sort the future games by date
      sorted_future_games = future_games.sort_by(&:date)
      
      # Return the next 3 games
      render json: sorted_future_games.first(3)
    end
  
    def find_fixtures_next_month
      # Get the current time
      current_time = Time.now
      
      # Calculate the next month's start and end dates
      next_month = current_time.next_month
      start_date = next_month.beginning_of_month
      end_date = next_month.end_of_month
    
      # Query the fixtures within the date range
      @fixtures = Fixture.where(date: start_date..end_date)
  
      render json: @fixtures, status: :ok
  
    end

    def get_month_fixtures
      date = Time.now
      beginning_of_month = date.beginning_of_month
      end_of_month = date.end_of_month

      @fixtures = Fixture.where(date: beginning_of_month..end_of_month)

      if @fixtures.any?
        render json: @fixtures, status: :ok
      else
        render json: @fixtures.error
    end
  end


    def last_3_home_games
      # Get all fixtures where West Ham United is the home team
      @fixtures = Fixture.where(home_team: 'West Ham United')
      @last_3 = @fixtures.order(date: :desc).limit(3)

      render json: @last_3, status: :ok
    end


    def add_calendar_event
      fixture = Fixture.find(params[:id])
    
      cal = Icalendar::Calendar.new
      cal_event = Icalendar::Event.new
    
      cal_event.dtstart     = fixture.date
      cal_event.dtend       = fixture.date + 3.hours # adjust duration as needed
      cal_event.summary     = fixture.name
      cal_event.description = "#{fixture.competition} match between #{fixture.home_team} and #{fixture.away_team} at #{fixture.stadium}."
      cal_event.location    = fixture.stadium if fixture.respond_to?(:stadium)
    
      cal.add_event(cal_event)
      cal.publish
    
      send_data cal.to_ical,
                type: 'text/calendar; charset=utf-8',
                disposition: 'attachment',
                filename: "fixture_#{fixture.id}.ics"
    end
    
    
    
    
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_fixture
        @fixture = Fixture.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def fixture_params
        params.require(:fixture).permit(:home_team, :away_team, :stadium, :capacity, :date, :home_team_abb, :away_team_abb, :competition)
      end
  end
  