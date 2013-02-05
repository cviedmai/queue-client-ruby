require 'spec_helper'
describe Viki::Queue::Runner do
  describe "run" do
    it "polls the queue and noops a nil" do
      Viki::Queue.should_receive(:poll).with('the-queue').and_return(nil)
      Viki::Queue::Runner.run('the-queue', nil)
    end

    it "polls the queue and passes the event to the router" do
      e = {'resource' => 'application', 'action' => 'create'}
      Viki::Queue.should_receive(:poll).with('the-queue').and_return(e)
      Viki::Queue.should_receive(:close).with('the-queue')
      Viki::Queue::Runner.run('the-queue', FakeRouter)
    end

    it "iterates multiple times" do
      Viki::Queue.should_receive(:poll).with('the-queue').twice().and_return(nil)
      Viki::Queue::Runner.run('the-queue', FakeRouter, {iterations: 2})
    end
  end

  class FakeRouter
    def self.create_application(e)
      e.should == {'resource' => 'application', 'action' => 'create'}
      true
    end
  end
end

