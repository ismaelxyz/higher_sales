# frozen_string_literal: true

class ReportsCacheWarmWorker
  include Sidekiq::Worker
  sidekiq_options queue: :reports, retry: 2

  DEFAULT_LIMITS = [ 3 ].freeze

  def perform
    DEFAULT_LIMITS.each do |limit|
      Reports::TopProductsByCategoryQuery.call(limit: limit, cache: true)
      Reports::TopRevenueProductsByCategoryQuery.call(limit: limit, cache: true)
    end
  end

  private
end
