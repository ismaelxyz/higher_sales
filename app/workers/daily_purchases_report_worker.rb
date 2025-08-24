# frozen_string_literal: true

# DailyPurchasesReportWorker is a Sidekiq worker responsible for sending the daily purchases report email.
#
# This worker generates and sends a report for purchases made on a specific date.
# If no date is provided, it defaults to the previous day.
#
# Sidekiq Options:
#   - Queue: :default
#   - Retry: 3 times
#
# @example Enqueue a report for a specific date
#   DailyPurchasesReportWorker.perform_async('2024-06-10')
#
# @example Enqueue a report for the previous day
#   DailyPurchasesReportWorker.perform_async
#
# @param [String, nil] date_str Optional date string in 'YYYY-MM-DD' format. If nil, uses yesterday's date.
# @return [void]
class DailyPurchasesReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :reports, retry: 3

  # Performs the daily purchases report email for the previous day or a provided date.
  # @param [String,nil] date_str Optional date string (YYYY-MM-DD)
  def perform(date_str = nil)
    report_date = if date_str
      Date.parse(date_str)
    else
      Date.yesterday
    end

    ProductMailer.daily_purchases_report(report_date).deliver_later
  end
end
