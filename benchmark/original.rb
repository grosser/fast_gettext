require 'benchmark/base'

begin
  gem 'gettext', '>=2.0.0'
rescue LoadError
  puts 'To run this benchmark, please install the gettext gem'
  exit 1
end

$LOAD_PATH.unshift 'lib'
require 'gettext'
include GetText

self.locale = 'de'

puts "GetText #{GetText::VERSION}:"
bindtextdomain('test',:path=>locale_folder('test'))
results_test{_('car') == 'Auto'}

#i cannot add the large file, since its an internal applications mo file
bindtextdomain('large',:path=>locale_folder('large'))
results_large
