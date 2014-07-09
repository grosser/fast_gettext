# $VERBOSE = true # ignore complaints in spec files

# ---- requirements
require 'fast_gettext'
require 'active_record'

# ---- revert to defaults
RSpec.configure do |config|
  config.before do
    FastGettext.default_available_locales = nil
    FastGettext.available_locales = nil
    FastGettext.locale = 'de'
  end

  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.mock_with(:rspec) { |c| c.syntax = :should }
end

def default_setup
  # make sure all tests are really independent
  Thread.current[:fast_gettext_text_domain] = nil
  Thread.current[:fast_gettext__locale] = nil
  Thread.current[:fast_gettext_available_locales] = nil
  Thread.current[:fast_gettext_pluralisation_rule] = nil
  Thread.current[:fast_gettext_current_cache] = nil
  FastGettext.send(:class_variable_set, :@@translation_repositories, {})
  FastGettext.send(:class_variable_set, :@@caches, {})
  FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'locale'))
  FastGettext.text_domain = 'test'
  FastGettext.available_locales = ['en','de','gsw_CH']
  FastGettext.locale = 'de'
  FastGettext.send(:update_current_cache)
end

# TODO remove
def pending_if(condition, *args)
  pending(*args) if condition
  yield
end

def setup_extra_domain
  FastGettext.add_text_domain('test2',:path=>File.join(File.dirname(__FILE__),'locale'))
end
