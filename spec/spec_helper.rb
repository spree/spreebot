ENV['RACK_ENV'] = 'test'

require File.expand_path("../../app", __FILE__)

require 'rspec'
require 'rack/test'
require 'pry'

RSpec.configure do |config|
  config.color = true
  config.mock_with :rspec
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.include Rack::Test::Methods
end
