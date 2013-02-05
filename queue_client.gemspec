# -*- encoding: utf-8 -*-
require File.expand_path('../lib/queue_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Viki"]
  gem.email         = ["engineering@viki.com"]
  gem.description   = %q{A client for viki's queue}
  gem.homepage      = "http://dev.viki.com"
  gem.summary       = %q{A client for viki's queue}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "queue_client"
  gem.require_paths = ["lib"]
  gem.version       = Viki::Queue::VERSION

  gem.add_development_dependency "rspec", ">= 2.12.0"
end