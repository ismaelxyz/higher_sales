ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# This module defines the ActiveSupport namespace and its TestCase class,
# which provides configuration for running tests in a Rails application.
#
# The TestCase class:
# - Enables parallel test execution using the number of available processors.
# - Loads all fixtures from the test/fixtures directory for use in tests.
#
# Usage:
#   Place your test cases inside classes that inherit from ActiveSupport::TestCase
#   to automatically benefit from parallelization and fixture loading.
module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
