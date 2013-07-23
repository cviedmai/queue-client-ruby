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
      routing_key = "#{Viki::Queue._service.routing}.#{payload[:resource]}.#{payload[:action]}"
      message = Oj.dump(payload, mode: :compat)
      opts = {routing_key: routing_key, timestamp: Time.now.to_i, persistent: true}
      attemps = 5
      while attemps > 0
        begin
          send_to_queue(message, opts)
          break
        rescue Exception => e
          attemps -= 1
          if attemps > 0
            sleep(0.5)
            Viki::Queue.reconnect()
          else
            Viki::Queue::Logger.log('Failed to write in queue. Exiting.', e)
          end
        end
      end
    end

    def send_to_queue(message, opts)
      Viki::Queue._service.exchange.publish(message, opts)
    end

    def write_many(payload)
      payload.each { |p| write(p) }
    end

    def prepare_message(payload)
      m = {action: payload[0], resource: payload[1], id: payload[2]}
      unless Viki::Queue.client_name.nil?
        m[:_meta] = {client_name: Viki::Queue.client_name}
      end
      m[:payload] = payload[3] unless payload[3].nil?
      m
    end
  end
end
