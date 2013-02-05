require 'spec_helper'

describe Viki::Queue::Event do
  describe "Poll" do
    it "polls the queue and returns nil" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request) do |request|
        request.method.should == "GET"
        request.path.should == '/v1/queues/dummy/events/head.json'
        FakeResponse.new('404', '{"ok":true}')
      end
      Viki::Queue::Event.poll('dummy')
    end

    it "polls the queue and returns the object" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request) do |request|
        request.method.should == "GET"
        request.path.should == '/v1/queues/dummy/events/head.json'
        FakeResponse.new('200', '{"id":43}')
      end
      Viki::Queue::Event.poll('dummy')
    end
  end
end