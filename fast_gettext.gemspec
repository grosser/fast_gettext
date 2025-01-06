# frozen_string_literal: true

name = "fast_gettext"
require_relative "lib/#{name}/version"

Gem::Specification.new name, FastGettext::VERSION do |s|
  s.summary = "A simple, fast, memory-efficient and threadsafe implementation of GetText"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = Dir["{lib/**/*.{rb,mo,rdoc},Readme.md,CHANGELOG,LICENSE}"]
  s.licenses = ["MIT", "Ruby"]
  s.required_ruby_version = '>= 3.2.0'
  s.add_runtime_dependency 'prime'
  s.add_runtime_dependency 'racc'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3', '~> 2.1' # need to match what latest activerecord requires
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'i18n'
  s.add_development_dependency 'bump'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-packaging'
  s.add_development_dependency 'single_cov'
  s.add_development_dependency 'forking_test_runner'
end
