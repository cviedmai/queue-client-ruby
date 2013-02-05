class Viki::Queue::Http
  def self.get(url)
    uri = URI.parse("http://#{configuration.host}:#{configuration.port}/v1/#{url}")
    req = Net::HTTP::Get.new(uri.path)
    Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
  end

  def self.post(url, body)
    uri = URI.parse("http://#{configuration.host}:#{configuration.port}/v1/#{url}")
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = JSON.fast_generate(body)
    Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
  end

  def self.delete(url)
    uri = URI.parse("http://#{configuration.host}:#{configuration.port}/v1/#{url}")
    req = Net::HTTP::Delete.new(uri.path)
    Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
  end

  private

  def self.configuration
    Viki::Queue.configuration
  end
end