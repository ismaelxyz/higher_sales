# README

This README would normally document whatever steps are necessary to get the
application up and running.

## Background Jobs (Sidekiq)

This project uses Sidekiq + sidekiq-cron for background processing (daily purchases report).

1. Start Redis:
```
docker run -d --name redis -p 6379:6379 redis:7-alpine
```
2. Start Sidekiq:
```
bundle exec sidekiq -C config/sidekiq.yml
```
3. Web UI is mounted at `/sidekiq`.

Daily report runs every day at 06:00 (server time) via cron schedule. To enqueue manually:
```
DailyPurchasesReportWorker.perform_async
```

Environment variable `REDIS_URL` can override default `redis://localhost:6379/0`.
