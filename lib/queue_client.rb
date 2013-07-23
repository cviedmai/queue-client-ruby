require 'oj'
require 'bunny'

module Viki
  module Queue
    @host = 'localhost'
    @port = 5672
    @username = 'guest'
    @password = 'guest'
    class << self
      attr_accessor :host, :port, :username, :password, :client_name, :_service
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
