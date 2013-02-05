class Viki::Queue::Event

  def self.poll(queue)
    res = Viki::Queue::Http.get("queues/#{queue}/events/head.json")
    return nil if res.code == '404'
    return JSON.parse(res.body) if res.code == '200'
    raise res.code + res.body
  end

  def self.close(queue)
    res = Viki::Queue::Http.delete("queues/#{queue}/events/head.json")
    return true if res.code == '200'
    raise res.code + res.body
  end

  def self.create(resource, id)
    self.write(to_hash([:create, resource, id]))
  end

  def self.update(resource, id)
    self.write(to_hash([:update, resource, id]))
  end

  def self.delete(resource, id)
    self.write(to_hash([:delete, resource, id]))
  end

  def self.bulk(*events)
    self.write(events.map {|e| to_hash(e)})
  end

  private

  def self.write(payload)
    res = Viki::Queue::Http.post('events.json', payload)
    return true if res.code == '201'
    raise res.body
  end

  def self.to_hash(event)
    {action: event[0], resource: event[1], id: event[2]}
  end
end