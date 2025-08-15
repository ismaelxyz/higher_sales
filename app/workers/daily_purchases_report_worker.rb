# frozen_string_literal: true

class DailyPurchasesReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  # Performs the daily purchases report email for the previous day or a provided date.
  # @param [String,nil] date_str Optional date string (YYYY-MM-DD)
  def perform(date_str = nil)
    report_date = if date_str
      Date.parse(date_str)
    else
      Date.yesterday
    end
    ProductMailer.daily_purchases_report(report_date).deliver_now
  end
end
