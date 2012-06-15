# $VERBOSE = true # ignore complaints in spec files

# ---- requirements
$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))
require 'fast_gettext'

# ---- revert to defaults
RSpec.configure do |config|
  config.before do
    FastGettext.locale = 'de'
    FastGettext.available_locales = nil
  end
end

def default_setup
  FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'locale'))
  FastGettext.text_domain = 'test'
  FastGettext.available_locales = ['en','de','gsw_CH']
  FastGettext.locale = 'de'
end
