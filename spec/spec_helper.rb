require './lib/queue_client'
require 'amqp'
require 'json'
Dir["./spec/support/**/*.rb"].each { |f| require f }
