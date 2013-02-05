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

    def self.register(queue, resources)
      res = self.http_post('queues.json', {name: queue, resources: resources})
      return true if res.code == '201'
      raise res.body
    end

    def self.poll(queue)
      res = self.http_get("queues/#{queue}/events/head.json")
      return nil if res.code == '404'
      return JSON.parse(res.body) if res.code == '200'
      raise res.body
    end

    def self.close(queue)
      res = self.http_delete("queues/#{queue}/events/head.json")
      return true if res.code == '200'
      raise res.body
    end

    def self.create(resource, id)
      self.write(resource, id, :create)
    end
    def self.update(resource, id)
      self.write(resource, id, :update)
    end
    def self.delete(resource, id)
      self.write(resource, id, :delete)
    end

    private
    def self.write(resource, id, action)
      res = self.http_post('events.json', {resource: resource, action: action, id: id})
      return true if res.code == '201'
      raise res.body
    end

    def self.http_get(url)
      uri = URI.parse("http://#{configuration.host}:#{configuration.port}/v1/#{url}")
      req = Net::HTTP::Get.new(uri.path)
      Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
    end
    def self.http_post(url, body)
      uri = URI.parse("http://#{configuration.host}:#{configuration.port}/v1/#{url}")
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      req.body = JSON.fast_generate(body)
      Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    end

    def self.http_delete(url)
      uri = URI.parse("http://#{configuration.host}:#{configuration.port}/v1/#{url}")
      req = Net::HTTP::Delete.new(uri.path)
      Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    end
  end
end

require_relative 'queue_client/version'
require_relative 'queue_client/configuration'