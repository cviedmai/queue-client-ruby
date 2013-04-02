module Viki::Queue
  class Service
    include Viki::Queue::Message
    include Viki::Queue::Runner

    attr_accessor :routing, :exchange, :buffer, :coalescing

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
      @buffer = []
      @coalescing = false
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

    def coalesce(&block)
      @coalescing = true
      block.call
      buffer = remove_dupes(@buffer)
      buffer = remove_noop(buffer)
      buffer.each do |b|
        message = b.first
        opts = b.last
        @exchange.publish(message, opts)
      end
    ensure
      @coalescing = false
      @buffer = []
    end

    def coalescing?
      @coalescing == true
    end

    private
    def get_routing_key(base, resource, action='#')
      k = "#{resource}.#{action}"
      k = "#{base}." + k unless @routing.empty?
      k
    end

    def remove_dupes(buffer)
      seen = []
      new_buffer = []
      buffer.each do |b|
        unless seen.include?(b.first)
          new_buffer << b
          seen << b.first
        end
      end
      new_buffer
    end

    def remove_noop(buffer)
      creates = []
      deletes = []
      buffer.each_with_index do |b, i|
        message = Oj.load(b.first, symbol_keys: true)
        if message[:action] == 'create'
          creates << [message[:resource], message[:id]]
          buffer[i+1..-1].each do |c|
            remain = Oj.load(c.first, symbol_keys: true)
            deletes << [remain[:resource], remain[:id]] if remain[:action] == 'delete'
          end
        end
      end
      noops = creates & deletes
      buffer.reject do |b|
        message = Oj.load(b.first, symbol_keys: true)
        noops.include? [message[:resource], message[:id]]
      end
    end
  end
end
