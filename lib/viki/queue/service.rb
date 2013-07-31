module Viki::Queue
  class Service
    include Viki::Queue::Message
    include Viki::Queue::Runner

    attr_accessor :routing, :exchange

    def initialize(opts={})
      @connection = Bunny.new({
        host: Viki::Queue.writer[:host],
        port: Viki::Queue.writer[:port],
        username: Viki::Queue.writer[:username],
        password: Viki::Queue.writer[:password],
        keepalive: true,
        threaded: false,
        socket_timeout: 0,
        connect_timeout: 0
      })
      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.topic(EXCHANGE, MESSAGE_SETTING)
      @routing = opts.fetch(:routing, 'resources')
    end

    def stop
      @connection.stop
    rescue
    end

    def subscribe(queue, resources)
      resources.each do |r|
        @channel.queue(queue, MESSAGE_SETTING).bind(@exchange, routing_key: get_routing_key(@routing, r))
      end
    end

    def unsubscribe(queue, resources)
      resources.each do |r|
        @channel.queue(queue, MESSAGE_SETTING).unbind(@exchange, routing_key: get_routing_key(@routing, r))
      end
    end

    def route(route)
      return if route.nil? or route == ""
      route = route[0...-1] if route[-1] == '.'
      @routing = route
    end

    def delete(queue)
      @channel.queue(queue, MESSAGE_SETTING).delete()
    end

    private

    def get_routing_key(base, resource, action='#')
      k = "#{resource}.#{action}"
      k = "#{base}." + k unless @routing.empty?
      k
    end
  end
end
