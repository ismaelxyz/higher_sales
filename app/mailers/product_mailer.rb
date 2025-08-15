class ProductMailer < ApplicationMailer
  default from: "notifications@example.com"

  def first_purchase_notification(product, client)
    @product = product
    @client = client
    creator = product.created_by_admin
    admins = Admin.where.not(id: creator.id).pluck(:email)

    mail(
      to: creator.email,
      cc: admins,
      subject: "First purchase of #{product.name}"
    )
  end

  # Sends a daily report with the purchases of each product for the previous day (or a given date)
  # Defaults to Date.yesterday to match requirement "del día anterior".
  def daily_purchases_report(report_date = Date.yesterday)
    @report_date = report_date
    start_time = report_date.beginning_of_day
    end_time = report_date.end_of_day

    # Aggregate products sold during the day using products_solds timestamps.
    @rows = ProductsSold
              .where(created_at: start_time..end_time)
              .joins(:product)
              .group("products.id")
              .select("products.name AS name, COUNT(products_solds.id) AS sold_count, COALESCE(SUM(products_solds.price),0) AS revenue")
              .order("products.name ASC")

    recipients = Admin.pluck(:email)
    mail(
      to: recipients,
      subject: "Daily Purchases Report for #{report_date}"
    )
  end
end
