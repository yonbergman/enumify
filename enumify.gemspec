# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "enumify/version"

Gem::Specification.new do |s|
  s.name        = "enumify"
  s.version     = Enumify::VERSION
  s.authors     = ["yon"]
  s.email       = ["yonatanbergman@gmail.com"]
  s.homepage    = "http://github.com/yonbergman/enumify"
  s.summary     = %q{enumify adds an enum command to all ActiveRecord models which enables you to work with string attributes as if they were enums}
  s.description = %q{enumify adds an enum command to all ActiveRecord models which enables you to work with string attributes as if they were enums}

  s.rubyforge_project = "enumify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "supermodel"
end
