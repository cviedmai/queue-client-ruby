class DummyConsumer < Viki::Queue::Consumer
  def initialize(config = nil)
    super "dummy", ["application"]
  end
end