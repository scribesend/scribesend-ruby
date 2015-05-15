$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'scribesend/version'

Gem::Specification.new do |spec|
  spec.name        = 'scribesend'
  spec.version     = Scribesend::VERSION
  spec.date        = Time.now.strftime("%Y-%m-%d")
  spec.summary     = 'Ruby bindings for Scribesend'
  spec.description = 'Scribesend builds APIs for accounting and business management: https://scribesend.com'
  spec.authors     = ['Frank Wu']
  spec.email       = 'frank@scribesend.com'
  spec.homepage    = 'https://www.scribesend.com/docs'
  spec.license     = 'MIT'

  spec.add_dependency 'rest-client', '~> 1.4'
  spec.add_dependency 'mime-types', '>= 1.25', '< 3.0'
  spec.add_dependency 'json', '~> 1.8.1'

  spec.files = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- test/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ['lib']
end