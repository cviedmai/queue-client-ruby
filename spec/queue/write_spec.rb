require 'spec_helper'
require 'net/http'

describe Viki::Queue do
  describe "write" do

    it "writes a create event" do
      assert('kitten', '22k', 'create')
      Viki::Queue.create(:kitten, '22k')
    end

    it "writes a update event" do
      assert('user', '9u', 'update')
      Viki::Queue.update(:user, '9u')
    end

    it "writes a delete event" do
      assert('application', '23a', 'delete')
      Viki::Queue.delete(:application, '23a')
    end

    private
    def assert(resource, id, action)
      http = mock(http)
      res = mock(http)
      Net::HTTP.any_instance.stub(:start).and_yield http
      http.should_receive(:request) do |request|
        request.method.should == "POST"
        request.path.should == '/v1/events.json'
        JSON.parse(request.body).should == {'action' => action, 'id' => id, 'resource' => resource}
        FakeResponse.new('201', '{"ok":true}')
      end
    end
  end
end