class DailyPurchasesReportJob < ApplicationJob
  # Deprecated: Replaced by `DailyPurchasesReportWorker` (Sidekiq)
  def perform(report_date = Date.yesterday)
    Rails.logger.warn("DailyPurchasesReportJob is deprecated. Use DailyPurchasesReportWorker instead.")
    DailyPurchasesReportWorker.perform_async(report_date.to_s)
  end
end
