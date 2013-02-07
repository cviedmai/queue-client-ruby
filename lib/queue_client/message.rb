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
    write(events.map {|e| to_hash(e)})
  end

  private

  def write(payload)
    payload = [payload] unless payload.class == Array
    payload.each do |p|
      routing_key = "resources.#{p[:resource]}.#{p[:action]}"
      ##Messages are not yet persisted!!!!
      @exchange.publish(Oj.dump(p), :routing_key => routing_key)
    end
  end

  def to_hash(payload)
    m = {action: payload[0], resource: payload[1], id: payload[2]}
    m[:payload] = payload[3] unless payload[3].nil?
    m
  end
end