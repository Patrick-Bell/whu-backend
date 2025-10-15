require 'sidekiq'
require 'sidekiq-cron'

Sidekiq::Cron::Job.create(
  name: 'Daily Upcoming Fixtures Email - every day at midnight',
  cron: '0 0 * * *',
  class: 'DailyFixtureEmailJob'
)
