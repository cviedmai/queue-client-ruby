require 'json'
class Viki::Queue::Runner
  def self.run(queue, router, config = {iterations: 1})

    loops = 0
    while true
      begin
        process(queue, router)
      rescue => e
        router.send(:error, e)
      end
      loops += 1
      break if loops == config[:iterations]
    end
  end

  private
  def self.process(queue, router)
    event = Viki::Queue::Event.poll(queue)
    unless event.nil?
      method = "#{event['action']}_#{event['resource']}"
      if router.send(method.to_sym, event) == true
        Viki::Queue::Event.close(queue)
      end
    end
  end
end