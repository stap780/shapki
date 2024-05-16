require "sidekiq"
require "sidekiq-scheduler"

Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
    }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
  }
end


Sidekiq.configure_server do |config|
  config.on(:startup) do
    #   Sidekiq.schedule = YAML.load_file(Rails.root.join("config", "sidekiq_scheduler", "#{Rails.env}.yml")) || {}
    Sidekiq.schedule = YAML.load_file(Rails.root.join("config", "sidekiq_scheduler.yml")) || {}
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end