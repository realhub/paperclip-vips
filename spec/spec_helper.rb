require "bundler/setup"
Bundler.setup

# We need this because of this https://github.com/thoughtbot/paperclip/pull/2369
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/try'
require "paperclip-vips"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
