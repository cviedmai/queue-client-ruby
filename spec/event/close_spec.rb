require 'spec_helper'

describe Viki::Queue::Event do
  describe "Close" do
    it "Closes the queue's head" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request) do |request|
        request.method.should == "DELETE"
        request.path.should == '/v1/queues/dummy/events/head.json'
        FakeResponse.new('200', '{"ok":true}')
      end
      Viki::Queue::Event.close('dummy')
    end
  end
end