ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'test/unit/rails/test_help'
require 'webrick'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end
