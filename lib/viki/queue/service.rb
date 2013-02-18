module Viki::Queue
  class Service
    include Viki::Queue::Message
    include Viki::Queue::Runner

    def initialize
      @connection = Bunny.new({
        host: Viki::Queue.host,
        port: Viki::Queue.port,
        username: Viki::Queue.username,
        password: Viki::Queue.password,
        keepalive: true,
        threaded: false,
        socket_timeout: 0,
        connect_timeout: 0})
      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.topic("general", durable: true)
      @routing = 'resources'
    end

    def stop
      @connection.stop
    end

    def subscribe(queue, resources)
      resources.each do |r|
        @channel.queue(queue, durable: true).bind(@exchange, :routing_key => "#{@routing}.#{r}.#")
      end
    end

    def unsubscribe(queue, resources)
      resources.each do |r|
        @channel.queue(queue, durable: true).unbind(@exchange, :routing_key => "#{@routing}.#{r}.#")
      end
    end

    def route(route)
      return if route.nil? or route == ""
      route = route[0...-1] if route[-1] == '.'
      @routing = route
    end

    def delete(queue)
      @channel.queue(queue, durable: true).delete()
    end
  end
end
