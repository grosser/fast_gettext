name = "fast_gettext"
require "./lib/#{name}/version"

Gem::Specification.new name, FastGettext::VERSION do |s|
  s.summary = "A simple, fast, memory-efficient and threadsafe implementation of GetText"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = Dir["{lib/**/*.{rb,mo,rdoc},Readme.md,CHANGELOG}"]
  s.licenses = ["MIT", "Ruby"]
  s.required_ruby_version = '>= 2.1.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'i18n'
  s.add_development_dependency 'bump'
  s.add_development_dependency 'wwtd'
end
