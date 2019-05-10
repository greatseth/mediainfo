require 'bundler/setup'
require 'mediainfo'
require 'spec_shared_contexts'
require 'spec_shared_examples'
require 'mediainfo/errors'
require 'mediainfo/tracks'
require 'pry'
require 'aws-sdk-s3'

RSpec.configure do |config|
  # Aws.config.update(stub_responses: true)

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context 'Shared variables'
end
