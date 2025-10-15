class FixtureMailer < ApplicationMailer

    def upcoming_fixture(fixture)
        @fixture = fixture
        mail(to: ENV['EMAIL'], subject: "Upcoming Game Reminder")
    end

end
