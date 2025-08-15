class DailyPurchasesReportJob < ApplicationJob
  queue_as :default

  # Perform the job for the previous day unless a specific date is passed
  def perform(report_date = Date.yesterday)
    ProductMailer.daily_purchases_report(report_date).deliver_now
  end
end
