# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "enumify/version"

Gem::Specification.new do |s|
  s.name        = "enumify"
  s.version     = Enumify::VERSION
  s.authors     = ["yonbergman"]
  s.email       = ["yonbergman@gmail.com"]
  s.homepage    = "http://github.com/yonbergman/enumify"
  s.summary     = %q{enumify adds an enum command to all ActiveRecord models which enables you to work with string attributes as if they were enums}
  s.description =  <<-END
    Enumify lets you add an enum command to ActiveRecord models

    There are four things that the enumify gems adds to your model
      Validation - The enumify adds a validation to make sure that the field only receives accepted values
      Super Cool Methods - adds ? and ! functions for each enum value (canceled? - is it canceled, canceled! - change the state to canceled)
      Callback support - you can add a x_callback method which will be called each time the status changes
      Scopes - you can easily query for values of the enum
  END
  s.license     = 'MIT'


  s.rubyforge_project = "enumify"

  s.files         = `git ls-files`.split("\n") - ["Gemfile.lock"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "activerecord", '>= 3.0'
  s.add_development_dependency 'appraisal', '>= 0.3.8'
end
