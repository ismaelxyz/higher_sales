# frozen_string_literal: true

# Sidekiq configuration. Uses Redis URL from ENV or defaults.
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" } }

  # Load cron schedule for daily report if present
  schedule = {
    "daily_purchases_report" => {
      "class" => "DailyPurchasesReportWorker",
      "cron" => "0 6 * * *", # every day at 06:00 server time
      "queue" => "reports"
    },
    "reports_cache_warm" => {
      "class" => "ReportsCacheWarmWorker",
      "cron" => "*/5 * * * *", # every 5 minutes
      "queue" => "reports"
    }
  }
  if defined?(Sidekiq::Cron) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash(schedule)
  end

  # Align AR connection pool with Sidekiq concurrency to avoid DB starvation
  if defined?(ActiveRecord)
    concurrency = Integer(ENV.fetch("SIDEKIQ_CONCURRENCY", 10))
    db_config = ActiveRecord::Base.connection_db_config
    if db_config && db_config.configuration_hash[:pool].to_i < concurrency
      ActiveRecord::Base.establish_connection(db_config.configuration_hash.merge(pool: concurrency))
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" } }
end
