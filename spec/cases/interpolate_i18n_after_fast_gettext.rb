$LOAD_PATH.unshift 'lib'

require 'fast_gettext'
raise unless "%{a}" %{:a => 1} == '1'
require 'i18n/core_ext/string/interpolate'
raise unless "%{a}" %{:a => 1} == '1'
