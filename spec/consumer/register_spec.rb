require 'spec_helper'
require 'net/http'

describe Viki::Queue::Consumer do
  describe "Register" do
    it "registers the queue" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request) do |request|
        request.method.should == "POST"
        request.path.should == '/v1/queues.json'
        JSON.parse(request.body).should == {"name"=>"dummy", "resources"=>["application"]}
        FakeResponse.new('201', '{"ok":true}')
      end
      DummyConsumer.register.should == true
    end

    it "raise an exception on failure" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request).and_return FakeResponse.new('400', '{"ok":false}')
      expect { DummyConsumer.register }.to raise_error
    end
  end
end