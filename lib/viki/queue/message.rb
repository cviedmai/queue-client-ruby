module Viki::Queue
  module Message
    def create_message(resource, id, payload=nil)
      write(prepare_message([:create, resource, id, payload]))
    end

    def update_message(resource, id, payload=nil)
      write(prepare_message([:update, resource, id, payload]))
    end

    def delete_message(resource, id, payload=nil)
      write(prepare_message([:delete, resource, id, payload]))
    end

    def bulk(*events)
      write_many(events.map { |e| prepare_message(e) })
    end

    private

    def write(payload)
      routing_key = "#{@routing}.#{payload[:resource]}.#{payload[:action]}"
      @exchange.publish(Oj.dump(payload, mode: :compat), routing_key: routing_key, timestamp: Time.now.to_i, persistent: true)
    end

    def write_many(payload)
      payload.each { |p| write(p) }
    end

    def prepare_message(payload)
      m = {action: payload[0], resource: payload[1], id: payload[2]}
      m[:payload] = payload[3] unless payload[3].nil?
      m
    end
  end
end
