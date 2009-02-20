FastGettext
===========
GetText but fast + simple + threadsave!

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
    include FastGettext
    _('Car') == 'Auto'
    _('not-found') == 'not-found'
    s_('Namespace|no-found') == 'not-found'
    n_('Axis','Axis',3) == 'Achsen' #German plural of Axis

Speed
=====
50_000 translations:
Ideal: (primitive Hash lookup)
    small translation file:
    1.070000   0.190000   1.260000 (  1.266628)
    mapped: 5832K    writeable/private: 3016K    shared: 28K

    large translation file:
    1.150000   0.160000   1.310000 (  1.327283)
    mapped: 5832K    writeable/private: 3016K    shared: 28K

FastGettext:
    small translation file:
    6.830000   0.670000   7.500000 (  7.498320)
    mapped: 5840K    writeable/private: 3024K    shared: 28K

    large translation file:
    7.010000   0.780000   7.790000 (  7.907242)
    mapped: 5972K    writeable/private: 3156K    shared: 28K

GetText:
    small translation file:
   16.090000   1.400000  17.490000 ( 17.652287)
    mapped: 8964K    writeable/private: 5932K    shared: 28K

    large translation file:
   16.800000   1.290000  18.090000 ( 18.173813)
    mapped: 9024K    writeable/private: 5992K    shared: 28K

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
      include FastGettext
      before_filter :set_locale
      def set_locale
        FastGettext.available_locales = ['de','en',...]
        FastGettext.text_domain = 'frontend'
        sessions[:locale] = I18n.locale = FastGettext.locale = params[:locale] || sessions[:locale] || 'en'
      end

    #application_helper.rb
    module ApplicationHelper
      include FastGettext
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