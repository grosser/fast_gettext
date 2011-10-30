$LOAD_PATH.unshift 'lib'
require 'fast_gettext'
$SAFE = 1
rep = FastGettext::TranslationRepository.build('safe_test',:path=>File.join('spec','locale'))
print rep.is_a?(FastGettext::TranslationRepository::Mo)
