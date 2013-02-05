require 'spec_helper'

describe Viki::Queue do
  describe "Delete" do
    it "deletes the queue" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request) do |request|
        request.method.should == "DELETE"
        request.path.should == '/v1/queues/gaia.json'
        FakeResponse.new('200', '{"ok":true}')
      end
      Viki::Queue.delete('gaia')
    end

    it "raise an exception on failure" do
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request).and_return FakeResponse.new('400', '{"ok":false}')
      expect { Viki::Queue.delete('gaia') }.to raise_error
    end
  end
end