# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "scamp/irc/version"

Gem::Specification.new do |s|
  s.name        = "scamp-irc"
  s.version     = Scamp::IRC::VERSION
  s.authors     = ["Adam Holt"]
  s.email       = ["me@adamholt.co.uk"]
  s.homepage    = ""
  s.summary     = %q{IRC Adapter for the Scamp bot framework}
  s.description = %q{Connect to IRC using the Scamp bot framework}

  s.rubyforge_project = "scamp-irc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_dependency "scamp", "2.0.0.pre"
  s.add_dependency "eventmachine", '1.0.0.beta.4'
  s.add_dependency "isaac", "0.2.6"

  s.add_development_dependency "rspec"
end
