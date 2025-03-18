require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.logger.level = :info
  config.redis = { url: ENV.fetch('REDIS_URL') }

  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(Rails.root.join('config/sidekiq_scheduler.yml'))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end

end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') }
end
