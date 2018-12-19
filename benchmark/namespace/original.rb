# frozen_string_literal: true

require 'rubygems'
initial = methods.count + Module.constants.count

# GetText
gem 'gettext', '>=2.0.0'
require 'gettext'
GetText.locale = 'de'
GetText.bindtextdomain('test', path: 'spec/locale')
include GetText # rubocop:disable Style/MixinUsage
raise unless _('car') == 'Auto'

puts "GetText"
puts methods.count + Module.constants.count - initial
