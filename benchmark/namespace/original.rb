require 'rubygems'
initial = methods.count + Module.constants.count

#GetText
gem 'gettext', '>=2.0.0'
require 'gettext'
include GetText

puts "GetText"
puts methods.count + Module.constants.count - initial