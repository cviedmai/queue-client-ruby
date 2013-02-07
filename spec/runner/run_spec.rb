require 'spec_helper'

describe Viki::Queue::Runner do
  describe "run" do
    it "polls the queue and noops a nil" do
      q = Viki::Queue.new()
      q.subscribe('a_queue', ['application'])
      q.create_message(:application, '22a')
      Viki::Queue::Runner.run('a_queue', FakeRouter)
      q.delete('a_queue')
    end

    it "iterates multiple times" do
      q = Viki::Queue.new()
      q.subscribe('the-queue', ['application', 'video'])
      q.create_message(:application, '22a')
      q.update_message(:video, '1v')
      Viki::Queue::Runner.run('the-queue', FakeRouter, {iterations: 2, host: 'localhost', port: 5672})
      q.delete('the-queue')
    end
  end

  class FakeRouter
    def self.create_application(e)
      {'resource' => 'application', 'action' => 'create', 'id' => '22a'}.should == e
      true
    end

    def self.update_video(e)
      {'resource' => 'video', 'action' => 'update', 'id' => '1v'}.should == e
      true
    end
  end
end