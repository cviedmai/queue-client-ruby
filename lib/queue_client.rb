require 'oj'
require 'bunny'

module Viki
  module Queue
    EXCHANGE = "general"
    MESSAGE_SETTING = {durable: true}
    DEFAULT_SETTINGS = {host: 'localhost', port: 5672, username: 'guest', password: 'guest'}

    @reader = DEFAULT_SETTINGS.clone
    @writer = DEFAULT_SETTINGS.clone

    class << self
      attr_accessor :reader, :writer, :client_name, :_service
    end

    def self.configure(&block)
      block.call self
      raise "Viki::Queue.client_name not set" unless client_name
      nil
    end

    def self.service
      Viki::Queue._service ||= Service.new
    end

    def self.reconnect
      Viki::Queue._service.stop
      Viki::Queue._service = Service.new({routing: Viki::Queue._service.routing})
    end
  end
end

require_relative 'viki/queue/logger'
require_relative 'viki/queue/message'
require_relative 'viki/queue/runner'
require_relative 'viki/queue/service'
require_relative 'viki/queue/version'