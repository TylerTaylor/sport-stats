# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sport_stats/version'

Gem::Specification.new do |spec|
  spec.name          = "sport_stats"
  spec.version       = SportStats::VERSION
  spec.authors       = ["tylertaylor"]
  spec.email         = ["vikingtyty@gmail.com"]

  spec.summary       = %q{Sport Stats}
  spec.description   = %q{Provides quick and easy access to sports stats.}
  spec.homepage      = "https://github.com/TylerTaylor/sport-stats"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "nokogiri", ">= 0"
  spec.add_development_dependency "pry", ">= 0"

  #spec.add_dependency "nokogiri", ">= 0"
  spec.add_development_dependency 'command_line_reporter', '>=3.0'
end
