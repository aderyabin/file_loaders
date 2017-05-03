require "bundler/setup"
require "file_loaders"

Settings = Struct.new(:source_dir, :processed_dir, :host, :user)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
