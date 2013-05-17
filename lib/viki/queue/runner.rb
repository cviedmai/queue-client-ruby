require 'amqp'

module Viki::Queue
  module Runner
    def run(queue, router, config={})
      config = {iterations: 1, fail_pause: 10}.merge(config)

      begin
        EventMachine.run do
          connection = AMQP.connect({
            host: Viki::Queue.host,
            port: Viki::Queue.port,
            username: Viki::Queue.username,
            password: Viki::Queue.password})
          channel = AMQP::Channel.new(connection)
          loops = 0
          channel.prefetch(1).queue(queue, :durable => true).subscribe(:ack => true) do |metadata, message|
            processed = false
            for i in 1..10 do
              begin
                payload = Oj.load(message, symbol_keys: true)
                payload[:_meta] = {timestamp: metadata.timestamp}
                if process(router, payload) == true
                  processed = true
                  metadata.ack
                  break
                end
              rescue => e
                router.error(e)
              end
              sleep(config[:fail_pause])
            end

            unless processed
              router.error("Failed to process message: #{message}")
              connection.close { EventMachine.stop }
            end

            loops += 1
            if loops == config[:iterations]
              connection.close { EventMachine.stop }
            end
          end
        end
      rescue Interrupt
        puts "Queue is interrupt. Good night!"
      end
    end

    private

    def process(router, message)
      unless message.nil?
        method = "#{message[:action]}_#{message[:resource]}"
        router.send(method, message)
      end
    end
  end
end
