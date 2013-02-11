require 'zlib'

module Viki::Queue
  class Compress
    def self.gzip(value)
      value = Oj.dump(value)
      buf = StringIO.new
      gz = Zlib::GzipWriter.new(buf)
      gz.write value
      gz.close
      buf.string
    end

    def self.gunzip(value)
      buf = StringIO.new(value)
      gz = Zlib::GzipReader.new(buf)
      uncompressed = gz.read
      gz.close
      Oj.load(uncompressed)
    end
  end
end