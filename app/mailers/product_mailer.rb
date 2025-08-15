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
end
