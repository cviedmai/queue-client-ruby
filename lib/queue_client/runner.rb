require 'amqp'
require 'json'

class Viki::Queue::Runner
  def self.run(queue, router, config = {iterations: 1, host: 'localhost', port: 5672})
    EventMachine.run do
      connection = AMQP.connect(host: config[:host], port: config[:port])
      channel = AMQP::Channel.new(connection)
      loops = 0
      begin
        channel.queue(queue, :durable => true).subscribe(:ack => true) do |metadata, message|
          process(router, JSON.parse(message), metadata)
          loops += 1
          if loops == config[:iterations]
            connection.close { EventMachine.stop }
          end
        end
      rescue => e
        router.send(:error, e)
      end
    end
  end

  private
  def self.process(router, message, metadata)
    unless message.nil?
      method = "#{message['action']}_#{message['resource']}"
      if router.send(method.to_sym, message) == true
        metadata.ack
      end
    end
  end
end