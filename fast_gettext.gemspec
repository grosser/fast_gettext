# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fast_gettext}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Grosser"]
  s.date = %q{2009-02-19}
  s.email = %q{grosser.michael@gmail.com}
  s.files = ["VERSION.yml", "README.markdown", "lib/fast_gettext.rb", "lib/fast_gettext", "lib/fast_gettext/storage.rb", "lib/fast_gettext/mo_file.rb", "spec/fast_gettext_spec.rb", "spec/spec_helper.rb", "spec/locale", "spec/locale/en", "spec/locale/en/LC_MESSAGES", "spec/locale/en/LC_MESSAGES/test.mo", "spec/locale/de", "spec/locale/de/LC_MESSAGES", "spec/locale/de/LC_MESSAGES/test.mo", "spec/fast_gettext", "spec/fast_gettext/storage_spec.rb", "spec/fast_gettext/mo_file_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/grosser/fast_gettext}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A simple, fast and threadsafe implementation of GetText}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
