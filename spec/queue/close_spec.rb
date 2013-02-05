require 'spec_helper'
require 'net/http'

describe Viki::Queue do
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
      Viki::Queue.close('dummy')
    end
  end
end