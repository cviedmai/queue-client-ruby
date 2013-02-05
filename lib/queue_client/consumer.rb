require 'json'
require 'net/http'

class Viki::Queue::Consumer
  def initialize(name, resources)
    @name = name
    @resources = resources
  end

  def self.register(config = {})
    consumer = self.new
    consumer.send(:set_config, config)
    consumer.send(:register)
  end

  def self.run(config = {})
    consumer = self.new
    consumer.send(:set_config, config)
    consumer.send(:poll)
  end

  def poll
    uri = URI.parse("http://#{@config.host}/v1/queues/#{@name}/events/head.json")
    req = Net::HTTP::Get.new(uri.path)
    res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
    if res.code == '404'
      process(nil)
    elsif res.code == '200'
      process(JSON.parse(res.body))
    else
      raise res.body
    end
  end

  def close
    uri = URI.parse("http://#{@config.host}/v1/queues/#{@name}/events/head.json")
    req = Net::HTTP::Delete.new(uri.path)
    res = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    return true if res.code == '200'
    raise JSON.parse(res.body)['error']
  end

  private
  def set_config(config)
    @config = Viki::Queue::Configuration.load(config)
  end

  def register
    uri = URI.parse("http://#{@config.host}/v1/queues.json")
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = JSON.fast_generate({name: @name, resources: @resources})
    res = Net::HTTP.new(uri.host, uri.port).start do |http|
      http.request(req)
    end
    return true if res.code == '201'
    raise JSON.parse(res.body)['error']
  end
end