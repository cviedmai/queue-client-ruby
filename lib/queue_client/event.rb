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
    self.write(resource, id, :create)
  end

  def self.update(resource, id)
    self.write(resource, id, :update)
  end

  def self.delete(resource, id)
    self.write(resource, id, :delete)
  end

  private

  def self.write(resource, id, action)
    res = Viki::Queue::Http.post('events.json', {resource: resource, action: action, id: id})
    return true if res.code == '201'
    raise res.body
  end
end