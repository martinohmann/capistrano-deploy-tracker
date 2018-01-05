# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deploy_tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "deploy_tracker"
  spec.version       = DeployTracker::VERSION
  spec.authors       = ["Martin Ohmann"]
  spec.email         = ["martin.ohmann@lesara.de"]
  spec.description   = %q{Publishes deploy info to deploy tracker api}
  spec.summary       = %q{Publishes deploy info to deploy tracker api}
  spec.homepage      = "https://git.lesara.de/infrastructure/capistrano-deploy-tracker"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.required_ruby_version = '>= 2.0.0'

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
