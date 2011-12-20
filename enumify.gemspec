# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "enumify/version"

Gem::Specification.new do |s|
  s.name        = "enumify"
  s.version     = Enumify::VERSION
  s.authors     = ["yon"]
  s.email       = ["yonatanbergman@gmail.com"]
  s.homepage    = "http://github.com/yonbergman/enumify"
  s.summary     = %q{Enumify adds an enum command for ActiveRecord that changes a string column/attribute to an enum}
  s.description = %q{enumify rocks}

  s.rubyforge_project = "enumify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "supermodel"
  # s.add_runtime_dependency "rest-client"
end
