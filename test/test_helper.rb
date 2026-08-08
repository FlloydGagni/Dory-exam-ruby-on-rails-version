ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Rate-limit counters live in Rails.cache, not the database, so fixture rollback
    # doesn't reset them between tests sharing a worker process. Clear it every test.
    setup { Rails.cache.clear }

    # Add more helper methods to be used by all tests here...
  end
end
