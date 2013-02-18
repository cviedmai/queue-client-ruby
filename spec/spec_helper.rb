require_relative '../lib/queue_client'
require 'amqp'
require 'json'
Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:each) {
    Viki::Queue.configure do |c|
      c.host = 'localhost'
      c.port = 5672
      c.username = 'guest'
      c.password = 'guest'
    end
  }
end