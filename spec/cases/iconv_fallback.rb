$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift File.join('spec','cases','fake_load_path')

# test that iconv cannot be found
test = 1
begin
  require 'iconv'
rescue LoadError
  test = 2
end
raise unless test == 2

# use FastGettext like normal and see if it fails
require 'fast_gettext'

FastGettext.add_text_domain('test',:path=>File.join('spec','locale'))
FastGettext.text_domain = 'test'
FastGettext.available_locales = ['en','de']
FastGettext.locale = 'de'

#translate
raise unless FastGettext._('car') == 'Auto'
