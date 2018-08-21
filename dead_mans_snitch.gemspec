# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'dead_mans_snitch'
  s.version = '1.1.2'

  s.authors = ['Kyle Burton <kyle.burton@gmail.com>']
  s.date = '2012-10-07'
  s.description = 'A gem to make using https://deadmanssnitch.com simple.'
  s.email = ['kburton@gmail.com']
  s.extra_rdoc_files = ['README.textile']
  s.files = ['README.textile', 'lib/dead_mans_snitch.rb', 'lib/dead_mans_snitch/middleware.rb']
  s.has_rdoc = false
  s.homepage = 'https://github.com/kyleburton/dead-mans-snitch'
  s.require_paths = ['lib']
  s.rubygems_version = '1.3.1'
  s.summary = 'A gem to make using https://deadmanssnitch.com simple.'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec', '>= 3.0.0'
  s.add_development_dependency 'sidekiq'
  s.add_development_dependency 'webmock'
end
