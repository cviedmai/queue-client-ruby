require "bunny"
require 'oj'


module Viki
  module Queue
    class << self
      attr_accessor :host, :port, :_service
    end

    def self.configure(&block)
      configurator = Viki::Queue::Configurator.new
      block.call configurator

      @host = configurator.host
      @port = configurator.port
      Oj.default_options = {mode: :compat, symbol_keys: true}
      nil
    end

    def self.service
      Viki::Queue._service ||= Service.new
    end

    class Configurator
      attr_accessor :host, :port

      def initialize
        @host = "localhost"
        @port = "5672"
      end
    end
  end
end

require_relative 'viki/queue/message'
require_relative 'viki/queue/runner'
require_relative 'viki/queue/service'
require_relative 'viki/queue/version'
