require 'amqp'

module Viki::Queue
  module Runner
    def run(queue, router, config={})
      config = {iterations: 1, fail_pause: 10}.merge(config)

      begin
        EventMachine.run do
          connection = AMQP.connect({
            host: Viki::Queue.reader[:host],
            port: Viki::Queue.reader[:port],
            username: Viki::Queue.reader[:username],
            password: Viki::Queue.reader[:password]
          })

          connection.on_tcp_connection_loss do |conn, settings|
            conn.reconnect
          end

          connection.on_recovery do
            Viki::Queue::Logger.log("Recovered connection @ #{Time.now}")
          end

          
          channel = AMQP::Channel.new(connection)
          channel.auto_recovery = true
          loops = 0
          channel.prefetch(1).queue(queue, MESSAGE_SETTING).subscribe(:ack => true) do |metadata, message|
            processed = false
            for i in 1..10 do
              begin
                payload = Oj.load(message, symbol_keys: true)
                if payload[:_meta]
                  payload[:_meta][:timestamp] = metadata.timestamp
                else
                  payload[:_meta] = {timestamp: metadata.timestamp}
                end

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
