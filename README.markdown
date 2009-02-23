FastGettext
===========
GetText but 8 times faster, simple, clean namespace (7 vs 34) and threadsave!

[Example Rails application](https://github.com/grosser/gettext_i18n_rails_example)

Setup
=====
    sudo gem install grosser-fast_gettext -s http://gems.github.com/

Tell Gettext where your mo-files lie:
    #e.g. for locale/de/LC_MESSAGES/my_app.mo
    FastGettext.add_text_domain('my_app',:path=>'locale')

Choose text domain, and locale for translation
    FastGettext.text_domain = 'my_app'
    FastGettext.available_locales = ['de','en','fr','en_US','en_UK'] # only allow these locales to be set (optional)
    FastGettext.locale = 'de'

Start translating
    include FastGettext::Translation
    _('Car') == 'Auto'
    _('not-found') == 'not-found'
    s_('Namespace|no-found') == 'not-found'
    n_('Axis','Axis',3) == 'Achsen' #German plural of Axis

Speed
=====
50_000 translations
small translation file <-> large translation file
    Baseline: (doing nothing in a loop)
    0.390000s / 2904K

    Ideal: (primitive Hash lookup)
    1.010000s / 3016K <-> 1.040000s / 3016K

    FastGettext:
    1.860000s / 3040K <-> 1.830000s / 3040K

    GetText:
    14.880000s / 5816K <-> 14.810000s / 6008K

    Rails I18n Simple:
    31.200000s / 10044K


Thread Safety and Rails
=======================
`text_domains` is not stored thread-save, so that they can be added inside the `environment.rb`,  
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
        sessions[:locale] = I18n.locale = FastGettext.set_locale(params[:locale] || sessions[:locale] || 'en')
      end

    #application_helper.rb
    module ApplicationHelper
      include FastGettext::Translation
      ...

Updating translations
=====================
ATM you have to use the [original GetText](http://github.com/mutoh/gettext) to create and manage your po/mo-files.

Author
======
Mofile parsing from Masao Mutoh, see vendor/README

Michael Grosser  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  