#Iconv will not be defined, unless it is found -> normalize test results for users that have Iconv/those who do not have it
begin;require 'iconv';rescue;LoadError;end
initial = methods.count + Module.constants.count

#FastGettext
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','..','lib')
require 'fast_gettext'
include FastGettext::Translation

puts "FastGettext"
puts methods.count + Module.constants.count - initial