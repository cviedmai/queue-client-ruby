require 'spec_helper'

describe Viki::Queue::Runner do
  describe "run" do
    it "polls the queue and noops a nil" do
      fakeRouter = Class.new do
        def self.create_application(e)
          e[:resource].should == 'application'
          e[:action].should == 'create'
          e[:id].should == '22a'
          true
        end
        def self.error(e)
          puts(%{===> e: %s} % [(e).inspect])
        end
      end
      q = Viki::Queue.service
      q.subscribe('a_queue', ['application'])
      q.create_message(:application, '22a')
      q.run('a_queue', fakeRouter)
      q.delete('a_queue')
    end

    it "includes the timestamp and the existing meta" do
      fakeRouter = Class.new do
        def self.create_application(e)
          meta = e.delete(:_meta)
          meta.include?(:timestamp).should == true
          meta[:client_name].should == "testing"
          true
        end
        def self.error(e)
          puts(%{===> e: %s} % [(e).inspect])
        end
      end
      q = Viki::Queue.service
      q.subscribe('a_queue', ['application'])
      orig = Viki::Queue.client_name
      Viki::Queue.client_name = "testing"
      q.create_message(:application, '22a')
      Viki::Queue.client_name = orig
      q.run('a_queue', fakeRouter)
      q.delete('a_queue')
    end

    it "iterates multiple times" do
      fakeRouter = Class.new do
        class << self
          attr_accessor :count
        end
        def self.create_application(e)
          @count ||= 0
          @count += 1
          true
        end
        def self.update_video(e)
          @count ||= 0
          @count += 1
          true
        end
        def self.error(e)
          puts(%{===> e: %s} % [(e).inspect])
        end
      end
      Time.stub(:now).and_return(Time.at(323232323))
      q = Viki::Queue.service
      q.subscribe('the-queue', ['application', 'video'])
      q.create_message(:application, '22a')
      q.update_message(:video, '1v')
      q.run('the-queue', fakeRouter, iterations: 2)
      fakeRouter.count.should == 2
      q.delete('the-queue')
    end
  end
end
