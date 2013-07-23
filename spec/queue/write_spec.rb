require 'spec_helper'

describe Viki::Queue do
  describe "write" do
    it "writes a create event" do
      assert({action: 'create', resource: 'kitten', id: '22k', _meta: {client_name: 'testing'}}) do
        Viki::Queue.service.create_message(:kitten, '22k')
      end
    end

    it "writes an update event" do
      assert({action: 'update', resource: 'kitten', id: '22k', _meta: {client_name: 'testing'}}) do
        Viki::Queue.service.update_message(:kitten, '22k')
      end
    end

    it "writes a delete event" do
      assert({action: 'delete', resource: 'kitten', id: '22k', _meta: {client_name: 'testing'}}) do
        Viki::Queue.service.delete_message(:kitten, '22k')
      end
    end

    it "sends payload when provided" do
      assert({action: 'create', resource: 'kitten', id: '22k', payload: [1,2,3], _meta: {client_name: 'testing'}}) do
        Viki::Queue.service.create_message(:kitten, '22k', [1,2,3])
      end
    end

    it "writes multiple events at once" do
      assert([
        {action: 'create', resource: 'kitten', id: '22k', payload: 'some_payload', _meta: {client_name: 'testing'}},
        {action: 'delete', resource: 'dogs', id: '34', _meta: {client_name: 'testing'}}], 2) do
        Viki::Queue.service.bulk([:create, :kitten, '22k', 'some_payload'], [:delete, :dogs, '34'])
      end
    end

    it "writes the client name" do
      assert({action: 'create', resource: 'kitten', _meta: {client_name: 'testing'}, id: '22k', _meta: {client_name: 'testing'}}) do
        orig = Viki::Queue.client_name
        Viki::Queue.client_name = "testing"
        Viki::Queue.service.create_message(:kitten, '22k')
        Viki::Queue.client_name = orig
      end
    end

    private

    def assert(message, total=1)
      EventMachine.run do
        connection = AMQP.connect(host: Viki::Queue.host, port: Viki::Queue.port)
        channel = AMQP::Channel.new(connection)
        q = channel.queue("", exclusive: true)
        routing_key = message.class == Array ? "resources.#" : "resources.#{message[:resource]}.#"
        q.bind("general", routing_key: routing_key) do
          yield
        end
        count = 0
        q.subscribe do |m|
          m = Oj.load(m, symbol_keys: true)
          if message.class == Array
            message.include?(m).should == true
          else
            m.should == message
          end
          count += 1
          if count == total
           connection.close { EventMachine.stop }
         end
        end
      end
    end

  end
end
