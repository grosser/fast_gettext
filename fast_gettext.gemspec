$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
name = "fast_gettext"
require "#{name}/version"

Gem::Specification.new name, FastGettext::VERSION do |s|
  s.summary = "A simple, fast, memory-efficient and threadsafe implementation of GetText"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.licenses = ["MIT", "Ruby"]
end
