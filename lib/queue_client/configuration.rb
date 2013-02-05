class Viki::Queue::Configuration
  attr_accessor :host, :port
  def initialize
    @host = 'queue.viki.io'
    @port = 80
  end
end