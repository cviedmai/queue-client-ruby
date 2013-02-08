# -*- encoding: utf-8 -*-
require File.expand_path('../lib/queue_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Viki"]
  gem.email         = ["engineering@viki.com"]
  gem.description   = %q{A client for Viki's queue}
  gem.homepage      = "https://github.com/viki-org/queue-client"
  gem.summary       = %q{A client for Viki's queue}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "queue_client"
  gem.require_paths = ["lib"]
  gem.version       = Viki::Queue::VERSION

  gem.add_development_dependency "rspec", ">= 2.12.0"

  gem.add_runtime_dependency "bunny", "0.9.0.pre6"
  gem.add_runtime_dependency "eventmachine", "1.0.0"
  gem.add_runtime_dependency "amqp", "0.9.8"
  gem.add_runtime_dependency "oj", "2.0.3"
end