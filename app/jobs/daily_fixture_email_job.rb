class DailyFixtureEmailJob < ApplicationJob
  queue_as :default

  def perform
    start_date = Date.today.beginning_of_month
    end_date = Date.today.end_of_month
    
    fixtures = Fixture.where(date: start_date..end_date)

    fixtures.each do |fixture|
      FixtureMailer.upcoming_fixture(fixture).deliver_now
    end
  end
end
