FastGettext
===========
GetText but 3.5 x faster, 560 x less memory, simple, clean namespace (7 vs 34) and threadsafe!

It supports multiple backends (.mo, .po, .yml files, Database(ActiveRecord + any other), Chain, Loggers) and can easily be extended.

[Example Rails application](https://github.com/grosser/gettext_i18n_rails_example)

Comparison
==========
<table>
  <tr>
    <td></td>
    <td width="100">Hash</td>
    <td width="150">FastGettext</td>
    <td width="100">GetText</td>
    <td width="100">ActiveSupport I18n::Simple</td>
  </tr>
  <tr>
    <td>Speed*</td>
    <td>0.82s</td>
    <td>1.36s</td>
    <td>4.88s</td>
    <td>21.77s</td>
  </tr>
  <tr>
    <td>RAM*</td>
    <td>4K</td>
    <td>8K</td>
    <td>4480K</td>
    <td>10100K</td>
  </tr>
  <tr>
    <td>Included backends</td>
    <td></td>
    <td>db, yml, mo, po, logger, chain</td>
    <td>mo</td>
    <td>yml (db/key-value/po/chain in other I18n backends)</td>
  </tr>
</table>
<small>*50.000 translations with ruby enterprise 1.8.6 through `rake benchmark`</small>

Setup
=====
### 1. Install

    sudo gem install fast_gettext

### 2. Add a translation repository

From mo files (traditional/default)

    FastGettext.add_text_domain('my_app',:path => 'locale')

Or po files (less maintenance than mo)

    FastGettext.add_text_domain('my_app',:path => 'locale', :type => :po)
    # :ignore_fuzzy => true to not use fuzzy translations
    # :report_warning => false to hide warnings about obsolete/fuzzy translations

Or yaml files (use I18n syntax/indentation)

    FastGettext.add_text_domain('my_app', :path => 'config/locales', :type => :yaml)

Or database (scaleable, good for many locales/translators)

    # db access is cached <-> only first lookup hits the db
    require "fast_gettext/translation_repository/db"
    FastGettext::TranslationRepository::Db.require_models #load and include default models
    FastGettext.add_text_domain('my_app', :type => :db, :model => TranslationKey)

### 3. Choose text domain and locale for translation
Do this once in every Thread. (e.g. Rails -> ApplicationController)

    FastGettext.text_domain = 'my_app'
    FastGettext.available_locales = ['de','en','fr','en_US','en_UK'] # only allow these locales to be set (optional)
    FastGettext.locale = 'de'

### 4. Start translating

    include FastGettext::Translation
    _('Car') == 'Auto'
    _('not-found') == 'not-found'
    s_('Namespace|not-found') == 'not-found'
    n_('Axis','Axis',3) == 'Achsen' #German plural of Axis
    _('Hello %{name}!') % {:name => "Pete"} == 'Hello Pete!'


Managing translations
============
### mo/po-files
Generate .po or .mo files using GetText parser (example tasks at [gettext_i18n_rails](http://github.com/grosser/gettext_i18n_rails))

Tell Gettext where your .mo or .po files lie, e.g. for locale/de/my_app.po and locale/de/LC_MESSAGES/my_app.mo

    FastGettext.add_text_domain('my_app',:path=>'locale')

Use the [original GetText](http://github.com/mutoh/gettext) to create and manage po/mo-files.
(Work on a po/mo parser & reader that is easier to use has started, contributions welcome @ [get_pomo](http://github.com/grosser/get_pomo) )

###Database
[Example migration for ActiveRecord](http://github.com/grosser/fast_gettext/blob/master/examples/db/migration.rb)<br/>
The default plural seperator is `||||` but you may overwrite it (or suggest a better one..).

This is usable with any model DataMapper/Sequel or any other(non-database) backend, the only thing you need to do is respond to the self.translation(key, locale) call.
If you want to use your own models, have a look at the [default models](http://github.com/grosser/fast_gettext/tree/master/lib/fast_gettext/translation_repository/db_models) to see what you want/need to implement.

To manage translations via a Web GUI, use a [Rails application and the translation_db_engine](http://github.com/grosser/translation_db_engine)

Rails
=======================
Try the [gettext_i18n_rails plugin](http://github.com/grosser/gettext_i18n_rails), it simplifies the setup.<br/>
Try the [translation_db_engine](http://github.com/grosser/translation_db_engine), to manage your translations in a db.

Setting `available_locales`,`text_domain` or `locale` will not work inside the `evironment.rb`,
since it runs in a different thread then e.g. controllers, so set them inside your application_controller.

    #environment.rb after initializers
    Object.send(:include,FastGettext::Translation)
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
        FastGettext.set_locale(params[:locale] || session[:locale] || request.env['HTTP_ACCEPT_LANGUAGE'])
        session[:locale] = I18n.locale = FastGettext.locale
      end


Advanced features
=================
### Abnormal pluralisation
Plurals are selected by index, think of it as `['car', 'cars'][index]`<br/>
A pluralisation rule decides which form to use e.g. in english its `count == 1 ? 0 : 1`.<br/>
If you have any languages that do not fit this rule, you have to add a custom pluralisation rule.

Via Ruby:

    FastGettext.pluralisation_rule = lambda{|count| count > 5 ? 1 : (count > 2 ? 0 : 2)}

Via mo/pofile:

    Plural-Forms: nplurals=2; plural=n==2?3:4;

[Plural expressions for all languages](http://translate.sourceforge.net/wiki/l10n/pluralforms).

###default_text_domain
If you only use one text domain, setting `FastGettext.default_text_domain = 'app'`
is sufficient and no more `text_domain=` is needed

###default_locale
If the simple rule of "first `availble_locale` or 'en'" is not suficcient for you, set `FastGettext.default_locale = 'de'`.

###default_available_locales
Fallback when no available_locales are set

###Chains
You can use any number of repositories to find a translation. Simply add them to a chain and when
the first cannot translate a given key, the next is asked and so forth.

    repos = [
      FastGettext::TranslationRepository.build('new', :path=>'....'),
      FastGettext::TranslationRepository.build('old', :path=>'....')
    ]
    FastGettext.add_text_domain 'combined', :type=>:chain, :chain=>repos

###Logger
When you want to know which keys could not be translated or were used, add a Logger to a Chain:

    repos = [
      FastGettext::TranslationRepository.build('app', :path=>'....')
      FastGettext::TranslationRepository.build('logger', :type=>:logger, :callback=>lambda{|key_or_array_of_ids| ... }),
    }
    FastGettext.add_text_domain 'combined', :type=>:chain, :chain=>repos

If the Logger is in position #1 it will see all translations, if it is in position #2 it will only see the unfound.
Unfound may not always mean missing, if you choose not to translate a word because the key is a good translation, it will appear nevertheless.
A lambda or anything that responds to `call` will do as callback. A good starting point may be `examples/missing_translations_logger.rb`.

###Plugins
Want a xml version ?
Write your own TranslationRepository!

    #fast_gettext/translation_repository/xxx.rb
    module FastGettext
      module TranslationRepository
        class Wtf
          define initialize(name,options), [key], plural(*keys) and
          either inherit from TranslationRepository::Base or define available_locales and pluralisation_rule
        end
      end
    end

###Multi domain support

If you have more than one gettext domain, there are two sets of functions
available:

    include FastGettext::TranslationMultidomain

    d_("domainname", "string") # finds 'string' in domain domainname
    dn_("domainname", "string", "strings", 1) # ditto
    # etc.

These are helper methods so you don't need to write:

    FastGettext.text_domain = "domainname"
    _("string")

It is useful in Rails plugins in the views for example. The second set of
functions are D functions which search for string in _all_ domains. If there
are multiple translations in different domains, it returns them in random
order (depends on the Ruby hash implementation):

    include FastGettext::TranslationMultidomain

    D_("string") # finds 'string' in any domain
    # etc.

FAQ
===
 - [Problems with ActiveRecord messages?](http://wiki.github.com/grosser/fast_gettext/activerecord)
 - [Iconv require error in 1.9.2](http://exceptionz.wordpress.com/2010/02/03/how-to-fix-the-iconv-require-error-in-ruby-1-9)


TODO
====
 - Add a fallback for Iconv.conv in ruby 1.9.4 -> lib/fast_gettext/vendor/iconv
 - YML backend that reads ActiveSupport::I18n files

Author
======
Mo/Po-file parsing from Masao Mutoh, see vendor/README

### [Contributors](http://github.com/grosser/fast_gettext/contributors)
 - [geekq](http://www.innoq.com/blog/vd)
 - [Matt Sanford](http://blog.mzsanford.com)
 - [Antonio Terceiro](http://softwarelivre.org/terceiro)
 - [J. Pablo Fernández](http://pupeno.com)
 - Rudolf Gavlas
 - [Ramón Cahenzli](http://www.psy-q.ch)
 - [Rainux Luo](http://rainux.org)
 - [Dmitry Borodaenko](https://github.com/angdraug)
 - [Kouhei Sutou](https://github.com/kou)
 - [Hoang Nghiem](https://github.com/hoangnghiem)
 - [Costa Shapiro](https://github.com/costa)
 - [Jamie Dyer](https://github.com/kernow)
 - [Stephan Kulow](https://github.com/coolo)
 - [Fotos Georgiadis](https://github.com/fotos)
 - [Lukáš Zapletal](https://github.com/lzap)
 - [Dominic Cleal](https://github.com/domcleal)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT, some vendor parts under the same license terms as Ruby (see headers)<br/>
[![Build Status](https://travis-ci.org/grosser/fast_gettext.png)](https://travis-ci.org/grosser/fast_gettext)
