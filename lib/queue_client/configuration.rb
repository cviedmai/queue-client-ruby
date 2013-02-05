class Viki::Queue::Configuration
  ENVIRONMENTS = {
    production: {host: 'queue.viki.io'},
    development: {host: 'queue.dev.viki.io'}
  }
  attr_accessor :host

  def self.load(c = {})
    c[:host] = :production unless c.include?(:host)
    config = Viki::Queue::Configuration.new()
    config.host = c[:host].is_a?(Symbol) ? ENVIRONMENTS[c[:host]][:host] : c[:host]
    config
  end
end