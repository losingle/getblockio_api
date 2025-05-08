require 'getblockio_api'
require 'webmock/rspec'

# Disable all real network connections to ensure tests don't make actual API requests
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable RSpec expect syntax
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Enable mock objects
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Shared contexts and examples
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Randomize test order
  config.order = :random
  Kernel.srand config.seed
end

# Helper methods
def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

# Create test directory (if it doesn't exist)
FileUtils.mkdir_p(fixture_path) unless File.exist?(fixture_path)
