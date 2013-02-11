require 'oj'
Oj.default_options = {mode: :compat, symbol_keys: true}
require 'bunny'

module Viki
  module Queue
    @host = 'localhost'
    @port = 5672
    class << self
      attr_accessor :host, :port, :_service
    end

    def self.configure(&block)
      block.call self
      nil
    end

    def self.service
      Viki::Queue._service ||= Service.new
    end

  end
end

require_relative 'viki/queue/compress'
require_relative 'viki/queue/message'
require_relative 'viki/queue/runner'
require_relative 'viki/queue/service'
require_relative 'viki/queue/version'
