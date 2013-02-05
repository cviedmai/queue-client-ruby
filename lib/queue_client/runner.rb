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
    event = Viki::Queue.poll(queue)
    unless event.nil?
      parsed = JSON.parse(event)
      method = "#{parsed['action']}_#{parsed['resource']}"
      if router.send(method.to_sym, parsed) == true
        Viki::Queue.close(queue)
      end
    end
  end
end