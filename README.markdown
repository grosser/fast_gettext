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
FastGettext
    small:
    1.000000   0.130000   1.130000 (  1.132578)
    mapped: 8620K    writeable/private: 5588K    shared: 28K

    large:
    1.060000   0.100000   1.160000 (  1.163962)
    mapped: 8620K    writeable/private: 5588K    shared: 28K


GetText
    small:
    3.220000   0.260000   3.480000 (  3.478093)
    mapped: 9036K    writeable/private: 6004K    shared: 28K

    large:
    3.280000   0.230000   3.510000 (  3.511891)
    mapped: 9156K    writeable/private: 6124K    shared: 28K


Updating translations
=====================
ATM you have to use the [original GetText](http://github.com/mutoh/gettext) to create and manage your po/mo-files.

Author
======
Mofile parsing from Masao Mutoh, see vendor/README

Michael Grosser  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  