require 'amqp'
require 'json'

class Viki::Queue::Runner
  def self.run(queue, router, config={})
    config = {iterations: 1, host: 'localhost', port: 5672, fail_pause: 10}.merge(config)

    EventMachine.run do
      connection = AMQP.connect(host: config[:host], port: config[:port])
      channel = AMQP::Channel.new(connection)
      loops = 0
      channel.queue(queue, :durable => true).subscribe(:ack => true) do |metadata, message|
        while true
          begin
            if process(router, JSON.parse(message))
              metadata.ack
              break
            end
          rescue => e
            router.error(e)
          end
          sleep(config[:fail_pause])
        end

        loops += 1
        if loops == config[:iterations]
          connection.close { EventMachine.stop }
        end
      end
    end
  end

  private

  def self.process(router, message)
    unless message.nil?
      method = "#{message['action']}_#{message['resource']}"
      router.send(method, message)
    end
  end
end