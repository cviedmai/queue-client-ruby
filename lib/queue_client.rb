require 'json'
require 'net/http'

module Viki
  module Queue

    def self.configure
      yield(configuration)
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.create(queue, resources)
      res = Viki::Queue::Http.post('queues.json', {name: queue, resources: resources})
      return true if res.code == '201'
      raise res.code + res.body
    end

    def self.delete(queue)
      res = Viki::Queue::Http.delete("queues/#{queue}.json")
      return true if res.code == '200'
      raise res.code + res.body
    end
  end
end

require_relative 'queue_client/http'
require_relative 'queue_client/event'
require_relative 'queue_client/runner'
require_relative 'queue_client/version'
require_relative 'queue_client/configuration'