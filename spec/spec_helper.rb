require_relative '../lib/queue_client'
require 'amqp'
require 'json'
Dir["./spec/support/**/*.rb"].each { |f| require f }

Viki::Queue.configure do |config|
  config.host = "queue.dev.viki.io"
  config.port = "5672"
end
