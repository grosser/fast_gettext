FastGettext
===========
GetText but 8.21 times faster, simple, clean namespace (7 vs 34) and threadsave!

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
50_000 translations:
Ideal: (primitive Hash lookup)
    small translation file:
    1.080000   0.190000   1.270000 (  1.274699)
    mapped: 5832K    writeable/private: 3016K    shared: 28K

    large translation file:
    1.110000   0.200000   1.310000 (  1.305616)
    mapped: 5832K    writeable/private: 3016K    shared: 28K

FastGettext:
    small translation file:
    1.980000   0.310000   2.290000 (  2.285980)
    mapped: 5852K    writeable/private: 3036K    shared: 28K

    large translation file:
    1.990000   0.320000   2.310000 (  2.318801)
    mapped: 5852K    writeable/private: 3036K    shared: 28K

GetText:
    small translation file:
    16.210000   1.290000  17.500000 ( 17.511050)
    mapped: 8908K    writeable/private: 5876K    shared: 28K

    large translation file:
    16.340000   1.330000  17.670000 ( 17.679807)
    mapped: 9028K    writeable/private: 5996K    shared: 28K

Thread Safety and Rails
=======================
`text_domains` is not stored thread-save, so that they can be added inside the `environment.rb`,  
and do not need to be readded for every thread (parsing takes time...).

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
        sessions[:locale] = I18n.locale = FastGettext.locale = params[:locale] || sessions[:locale] || 'en'
      end

    #application_helper.rb
    module ApplicationHelper
      include FastGettext::Translation
      ...

Try the [gettext_i18n_rails plugin](http://github.com/grosser/gettext_i18n_rails), it simplifies the setup.

Updating translations
=====================
ATM you have to use the [original GetText](http://github.com/mutoh/gettext) to create and manage your po/mo-files.

Author
======
Mofile parsing from Masao Mutoh, see vendor/README

Michael Grosser  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  