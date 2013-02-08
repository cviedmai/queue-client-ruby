require 'oj'
Oj.default_options = {mode: :compat, symbol_keys: true}

module Message
  def create_message(resource, id, payload=nil)
    write(to_hash([:create, resource, id, payload]))
  end

  def update_message(resource, id, payload=nil)
    write(to_hash([:update, resource, id, payload]))
  end

  def delete_message(resource, id, payload=nil)
    write(to_hash([:delete, resource, id, payload]))
  end

  def bulk(*events)
    write_many(events.map {|e| to_hash(e)})
  end

  private

  def write(payload)
    routing_key = "#{@routing}.#{payload[:resource]}.#{payload[:action]}"
    @exchange.publish(Oj.dump(payload), routing_key: routing_key, timestamp: Time.now.to_i, persistent: true)
  end

  def write_many(payload)
    payload.each { |p| write(p) }
  end

  def to_hash(payload)
    m = {action: payload[0], resource: payload[1], id: payload[2]}
    m[:payload] = payload[3] unless payload[3].nil?
    m
  end
end