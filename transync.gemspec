# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'transync/version'

Gem::Specification.new do |spec|
  spec.name          = 'transync'
  spec.version       = Transync::VERSION
  spec.authors       = ['zigomir']
  spec.email         = ['zigomir@gmail.com']
  spec.description   = %q{Synchronize XLIFF translations with Google Drive document}
  spec.summary       = %q{Synchronize XLIFF translations with Google Drive document}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'google_drive'
  spec.add_runtime_dependency 'builder'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
