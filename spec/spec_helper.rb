# $VERBOSE = true # ignore complaints in spec files

require 'single_cov'
SingleCov.setup :rspec

require 'fast_gettext'
require 'active_record'

RSpec.configure do |config|
  config.before do
    FastGettext.default_available_locales = nil
    FastGettext.available_locales = nil
    FastGettext.locale = 'de'
    FastGettext.translation_repositories.clear
    Thread.current[:fast_gettext_text_domain] = nil
    Thread.current[:fast_gettext__locale] = nil
    Thread.current[:fast_gettext_available_locales] = nil
    Thread.current[:fast_gettext_pluralisation_rule] = nil
    Thread.current[:fast_gettext_cache] = nil
  end

  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.mock_with(:rspec) { |c| c.syntax = :should }
end

def default_setup
  FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'locale'))
  FastGettext.text_domain = 'test'
  FastGettext.available_locales = ['en','de','gsw_CH']
  FastGettext.locale = 'de'
  FastGettext.send(:switch_cache)
end

# TODO remove
def pending_if(condition, *args)
  pending(*args) if condition
  yield
end

def setup_extra_domain
  FastGettext.add_text_domain('test2',:path=>File.join(File.dirname(__FILE__),'locale'))
end
