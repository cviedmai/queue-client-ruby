require 'spec_helper'
require 'net/http'

describe Viki::Queue do
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
      Viki::Queue.register('dummy', ['application'])
    end

    it "raise an exception on failure" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request).and_return FakeResponse.new('400', '{"ok":false}')
      expect { Viki::Queue.register('dummy', ['application']) }.to raise_error
    end
  end
end