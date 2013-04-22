require 'spec_helper'

describe Viki::Queue::Runner do
  describe "run" do
    it "polls the queue and noops a nil" do
      q = Viki::Queue.service
      q.subscribe('a_queue', ['application'])
      q.create_message(:application, '22a')
      q.run('a_queue', FakeRouter)
      q.delete('a_queue')
    end

    it "iterates multiple times" do
      Time.stub(:now).and_return(Time.at(323232323))
      q = Viki::Queue.service
      q.subscribe('the-queue', ['application', 'video'])
      q.create_message(:application, '22a')
      q.update_message(:video, '1v')
      q.delete('the-queue')
    end
  end

  class FakeRouter
    def self.create_application(e)
      meta = e.delete(:_meta)
      meta.include?(:timestamp).should == true
      {resource: 'application', action: 'create', id: '22a'}.should == e
      true
    end

    def self.update_video(e)
      meta = e.delete(:_meta)
      meta.include?(:timestamp).should == true
      {resource: 'video', action: 'update', id: '1v'}.should == e
      true
    end

    def self.error(e)
      puts(%{===> e: %s} % [(e).inspect])
    end
  end
end
