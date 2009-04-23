FastGettext
===========
GetText but 3.5 x faster, 560 x less memory, simple, clean namespace (7 vs 34) and threadsave!

[Example Rails application](https://github.com/grosser/gettext_i18n_rails_example)

Setup
=====
    sudo gem install grosser-fast_gettext -s http://gems.github.com/

Or from source:
    git clone git://github.com/grosser/fast_gettext.git
    cd fast_gettext && rake install

Generate .po or .mo files using GetText parser (example tasks at [gettext_i18n_rails](http://github.com/grosser/gettext_i18n_rails))

Tell Gettext where your .mo or .po files lie:
    #e.g. for locale/de/my_app.po and locale/de/LC_MESSAGES/my_app.mo
    #add :type=>:po and it will read directly from po files (not recommended for production since po-parsing can crash!)
    FastGettext.add_text_domain('my_app',:path=>'locale')

Choose text domain and locale for translation
    FastGettext.text_domain = 'my_app'
    FastGettext.available_locales = ['de','en','fr','en_US','en_UK'] # only allow these locales to be set (optional)
    FastGettext.locale = 'de'

Start translating
    include FastGettext::Translation
    _('Car') == 'Auto'
    _('not-found') == 'not-found'
    s_('Namespace|no-found') == 'not-found'
    n_('Axis','Axis',3) == 'Achsen' #German plural of Axis

Disable translation errors(like no text domain setup) while doing e.g. console session / testing
    FastGettext.silence_errors

Performance
===========
50_000 translations speed / memory
small translation file <-> large translation file
(ruby enterprise 1.8.6, your results may vary, try `rake benchmark`)
    Baseline: (doing nothing in a loop)
    0.250000s / 0K <->

    Ideal: (primitive Hash lookup)
    0.820000s / 4K <-> 0.760000s / 4K

    FastGettext:
    1.360000s / 8K <-> 1.320000s / 8K

    GetText 2.0.1:
    4.880000s / 4480K <-> 4.810000s / 4480K

    ActiveSupport I18n::Backend::Simple :
    21.770000s / 10100K <->





Thread Safety and Rails
=======================
Parsed `text_domains` are not stored thread-save, so that they can be added inside the `environment.rb`,
and do not need to be readded for every thread (parsing takes time...).

###Rails
Try the [gettext_i18n_rails plugin](http://github.com/grosser/gettext_i18n_rails), it simplifies the setup.

Setting `available_locales`,`text_domain` or `locale` will not work inside the `evironment.rb`, since it runs in a different thread
then e.g. controllers, so set them inside your application_controller.  

    #environment.rb after initializers
    FastGettext.add_text_domain('accounting',:path=>'locale')
    FastGettext.add_text_domain('frontend',:path=>'locale')
    ...

    #application_controller.rb
    class ApplicationController ...
      include FastGettext::Translation
      before_filter :set_locale
      def set_locale
        FastGettext.available_locales = ['de','en',...]
        FastGettext.text_domain = 'frontend'
        session[:locale] = I18n.locale = FastGettext.set_locale(params[:locale] || session[:locale] || request.env['HTTP_ACCEPT_LANGUAGE'] || 'en')
      end

    #application_helper.rb
    module ApplicationHelper
      include FastGettext::Translation
      ...

Updating translations
=====================
ATM you have to use the [original GetText](http://github.com/mutoh/gettext) to create and manage your po/mo-files.  
I already started work on a po/mo parser & reader that is easier to use, contributions welcome @ [pomo](http://github.com/grosser/pomo)

Advanced features
=================
###Abnormal pluralisation
Pluralisation rules can be set directly via a lambda (see specs/), or by using the Gettext
plural definition (see spec/locale/en/test_plural.po or [Plural expressions for all languages](http://translate.sourceforge.net/wiki/l10n/pluralforms).

###default_text_domain
If you only use one text domain, setting `FastGettext.default_text_domain = 'app'`
is sufficient and no more `text_domain=` is needed

###default_locale
If the simple rule of "first `availble_locale` or 'en'" is not suficcient for you, simply set `FastGettext.default_locale = 'de'`.

###Chains
You can use any number of repositories to find a translation. Simply add them to a chain and when
the first cannot translate a given msgid, the next is asked and so forth.
    repos = [
      FastGettext::TranslationRepository.build('new', :path=>'....'),
      FastGettext::TranslationRepository.build('old', :path=>'....')
    ]
    FastGettext.add_text_domain 'combined', :type=>:chain, :chain=>repos

###Logger
When you want to know which keys could not be translated or were used, add a Logger to a Chain:
    repos = [
      FastGettext::TranslationRepository.build('app', :path=>'....')
      FastGettext::TranslationRepository.build('logger', :type=>:logger, :callback=>lamda{|msgid_or_array_of_ids| ... }),
    }
    FastGettext.add_text_domain 'combined', :type=>:chain, :chain=>repos
If the Logger is in position #1 it will see all translations, if it is in position #2 it will only see the unfound.
Unfound may not always mean missing, if you chose not to translate a word because the msgid is a good translation, it will appear nevertheless.
A lambda or anything that responds to `call` will do as callback. A good starting point may be `examples/missing_translations_logger.rb`.

###Plugins
Want a yml, xml, database version ?
Write your own TranslationRepository!
    #fast_gettext/translation_repository/xxx.rb
    module FastGettext
      module TranslationRepository
        class Wtf
          define initialize(name,options), [key], plural(*msgids) and
          either inherit from TranslationRepository::Base or define available_locales and pluralisation_rule
        end
      end
    end

FAQ
===
 - [Problems with ActiveRecord messages?](http://wiki.github.com/grosser/fast_gettext/activerecord)

TODO
====
 - use `default_locale=(x)` internally, atm the default is available_locales.first || 'en'
 - use `default_text_domain=(x)` internally, atm default is nil...

Author
======
Mo/Po-file parsing from Masao Mutoh, see vendor/README

###Contributors
 - [geekq](http://www.innoq.com/blog/vd)

[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  
