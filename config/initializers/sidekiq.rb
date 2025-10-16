require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end

Sidekiq::Cron::Job.create(
  name: 'Daily Upcoming Fixtures Email - every day at midnight',
  cron: '0 0 * * *',
  class: 'DailyFixtureEmailJob'
)
