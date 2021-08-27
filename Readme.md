FastGettext
===========
GetText but 12 x faster, 530 x less garbage, clean namespace (8 vs 26), simple and threadsafe!

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
    <td>0.08s</td>
    <td>0.14s</td>
    <td>1.75s</td>
    <td>3.75s</td>
  </tr>
  <tr>
    <td>Objects*</td>
    <td>11K</td>
    <td>15K</td>
    <td>8017K</td>
    <td>7107K</td>
  </tr>
  <tr>
    <td>Included backends</td>
    <td></td>
    <td>db, yml, mo, po, logger, chain</td>
    <td>mo</td>
    <td>yml (db/key-value/po/chain in other I18n backends)</td>
  </tr>
</table>
<small>*500.000 translations with ruby 2.5.3 through `bundle exec rake benchmark`</small>


Setup
=====

### 1. Install

```Bash
gem install fast_gettext
```

### 2. Add a translation repository

From mo files (traditional/default)

```Ruby
FastGettext.add_text_domain('my_app', path: 'locale')
```

Or po files (less maintenance than mo)

```Ruby
FastGettext.add_text_domain('my_app', path: 'locale', type: :po)
# ignore_fuzzy: true to not use fuzzy translations
# report_warning: false to hide warnings about obsolete/fuzzy translations
```

Or yaml files (use I18n syntax/indentation)

```Ruby
# A single locale can be segmented in multiple yaml files but they all should be
# named with a `qq.yml` suffix, where `qq` is the locale name.
FastGettext.add_text_domain('my_app', path: 'config/locales', type: :yaml)
```

Or database (scaleable, good for many locales/translators)

```Ruby
# db access is cached <-> only first lookup hits the db
require "fast_gettext/translation_repository/db"
FastGettext::TranslationRepository::Db.require_models # load and include default models
FastGettext.add_text_domain('my_app', type: :db, model: TranslationKey)
```

### 3. Choose text domain and locale for translation
Do this once in every Thread. (e.g. Rails -> ApplicationController)

```Ruby
FastGettext.text_domain = 'my_app'
FastGettext.available_locales = ['de', 'en', 'fr', 'en_US', 'en_UK'] # only allow these locales to be set (optional)
FastGettext.locale = 'de'
```

### 4. Start translating

FastGettext supports all the translation methods of [ruby-gettext](http://github.com/ruby-gettext/gettext) with added support for block defaults.
(to get `*gettext` methods, use `FastGettext::TranslationAliased`)

#### `_()` or `gettext()`: basic translation

```ruby
extend FastGettext::Translation
_('Car') == 'Auto'             # found translation for 'Car'
_('not-found') == 'not-found'  # The msgid is returned by default
```

#### `n_()` or `ngettext()`: pluralization

```ruby
n_('Car', 'Cars', 1) == 'Auto'
n_('Car', 'Cars', 2) == 'Autos' # German plural of Cars
```

You'll often want to interpolate the results of `n_()` using ruby builtin `%` operator.

```ruby
n_('Car', '%{n} Cars', 2) % { n: count } == '2 Autos'
```

#### `p_()` or `pgettext()`: translation with context

```ruby
p_('File', 'Open') == _("File\004Open") == "öffnen"
p_('Context', 'not-found') == 'not-found'
```

#### `s_()` or `sgettext()`: translation with namespace

```ruby
s_('File|Open') == _('File|Open') == "öffnen"
s_('Context|not-found') == 'not-found'
```

The difference between `s_()` and `p_()` is largely based on how the translations
are stored. Your preference will be based on your workflow and translation editing
tools.

#### `pn_()` or `pngettext()`: context-aware pluralized

```ruby
pn_('Fruit', 'Apple', 'Apples', 3) == 'Äpfel'
pn_('Fruit', 'Apple', 'Apples', 1) == 'Apfel'
```

#### `sn_()` or `sngettext()`: without context pluralized

```ruby
sn_('Fruit|Apple', 'Apples', 3) == 'Äpfel'
sn_('Fruit|Apple', 'Apples', 1) == 'Apfel'
```

#### `N_()` and `Nn_()`: make dynamic translations available to the parser.

In many instances, your strings will not be found by the ruby parsing. These methods
allow for those strings to be discovered.

```
N_("active"); N_("inactive"); N_("paused") # possible value of status for parser to find.
Nn_("active", "inactive", "paused")        # alternative method
_("Your account is %{account_state}.") % { account_state: _(status) }
```


Managing translations
=====================

### mo/po-files
Generate .po or .mo files using GetText parser (example tasks at [gettext_i18n_rails](http://github.com/grosser/gettext_i18n_rails))

Tell Gettext where your .mo or .po files lie, e.g. for locale/de/my_app.po and locale/de/LC_MESSAGES/my_app.mo

```Ruby
FastGettext.add_text_domain('my_app', path: 'locale')
```

Use the [original GetText](http://github.com/ruby-gettext/gettext) to create and manage po/mo-files.
(Work on a po/mo parser & reader that is easier to use has started, contributions welcome @ [get_pomo](http://github.com/grosser/get_pomo) )

### Database
[Example migration for ActiveRecord](http://github.com/grosser/fast_gettext/blob/master/examples/db/migration.rb)<br/>
The default plural separator is `||||` but you may overwrite it (or suggest a better one...).

This is usable with any model DataMapper/Sequel or any other(non-database) backend, the only thing you need to do is respond to the self.translation(key, locale) call.
If you want to use your own models, have a look at the [default models](http://github.com/grosser/fast_gettext/tree/master/lib/fast_gettext/translation_repository/db_models) to see what you want/need to implement.

To manage translations via a Web GUI, use a [Rails application and the translation_db_engine](http://github.com/grosser/translation_db_engine)

Rails
=======================
Try the [gettext_i18n_rails plugin](http://github.com/grosser/gettext_i18n_rails), it simplifies the setup.<br/>
Try the [translation_db_engine](http://github.com/grosser/translation_db_engine), to manage your translations in a db.

Setting `available_locales`,`text_domain` or `locale` will not work inside the `environment.rb`,
since it runs in a different thread then e.g. controllers, so set them inside your application_controller.

```Ruby
# config/environment.rb after initializers
Object.send(:include, FastGettext::Translation)
FastGettext.add_text_domain('accounting', path: 'locale')
FastGettext.add_text_domain('frontend', path: 'locale')
...

# app/controllers/application_controller.rb
class ApplicationController ...
  include FastGettext::Translation
  before_filter :set_locale
  def set_locale
    FastGettext.available_locales = ['de', 'en', ...]
    FastGettext.text_domain = 'frontend'
    FastGettext.set_locale(params[:locale] || session[:locale] || request.env['HTTP_ACCEPT_LANGUAGE'])
    session[:locale] = I18n.locale = FastGettext.locale
  end
```


Advanced features
=================

### Abnormal pluralisation
Plurals are selected by index, think of it as `['car', 'cars'][index]`<br/>
A pluralisation rule decides which form to use e.g. in english its `count == 1 ? 0 : 1`.<br/>
If you have any languages that do not fit this rule, you have to add a custom pluralisation rule.

Via Ruby:

```Ruby
FastGettext.pluralisation_rule = ->(count){ count > 5 ? 1 : (count > 2 ? 0 : 2)}
```

Via mo/pofile:

```
Plural-Forms: nplurals=2; plural=n==2?3:4;
```

[Plural expressions for all languages](http://translate.sourceforge.net/wiki/l10n/pluralforms).

### default_text_domain
If you only use one text domain, setting `FastGettext.default_text_domain = 'app'`
is sufficient and no more `text_domain=` is needed

### default_locale
If the simple rule of "first `available_locale` or 'en'" is not sufficient for you, set `FastGettext.default_locale = 'de'`.

### default_available_locales
Fallback when no available_locales are set

### with_locale
If there is content from different locales that you wish to display, you should use the with_locale option as below:

```Ruby
FastGettext.with_locale 'gsw_CH' do
  FastGettext._('Car was successfully created.')
end
# => "Z auto isch erfolgriich gspeicharat worda."
```

### Chains
You can use any number of repositories to find a translation. Simply add them to a chain and when
the first cannot translate a given key, the next is asked and so forth.

```Ruby
repos = [
  FastGettext::TranslationRepository.build('new', path: '....'),
  FastGettext::TranslationRepository.build('old', path: '....')
]
FastGettext.add_text_domain 'combined', type: :chain, chain: repos
```

### Merge
In some cases you can benefit from using merge repositories as an alternative to chains. They behave nearly the same. The difference is in the internal
data structure. While chain repos iterate over the whole chain for each translation, merge repositories select and store the first translation at the time
a subordinate repository is added. This puts the burden on the load phase and speeds up the translations.

```Ruby
repos = [
  FastGettext::TranslationRepository.build('new', path: '....'),
  FastGettext::TranslationRepository.build('old', path: '....')
]
domain = FastGettext.add_text_domain 'combined', type: :merge, chain: repos
```

Downside of this approach is that you have to reload the merge repo each time a language is changed.

```Ruby
FastGettext.locale = 'de'
domain.reload
```

### Logger
When you want to know which keys could not be translated or were used, add a Logger to a Chain:

```Ruby
repos = [
  FastGettext::TranslationRepository.build('app', path: '....')
  FastGettext::TranslationRepository.build('logger', type: :logger, callback: ->(key_or_array_of_ids) { ... }),
}
FastGettext.add_text_domain 'combined', type: :chain, chain: repos
```

If the Logger is in position #1 it will see all translations, if it is in position #2 it will only see the unfound.
Unfound may not always mean missing, if you choose not to translate a word because the key is a good translation, it will appear nevertheless.
A lambda or anything that responds to `call` will do as callback. A good starting point may be `examples/missing_translations_logger.rb`.

### Plugins
Want an xml version?
Write your own TranslationRepository!

```Ruby
# fast_gettext/translation_repository/wtf.rb
module FastGettext
  module TranslationRepository
    class Wtf
      define initialize(name,options), [key], plural(*keys) and
      either inherit from TranslationRepository::Base or define available_locales and pluralisation_rule
    end
  end
end
```

### Multi domain support

If you have more than one gettext domain, there are two sets of functions
available:

```Ruby
extend FastGettext::TranslationMultidomain

d_("domainname", "string") # finds 'string' in domain domainname
dn_("domainname", "string", "strings", 1) # ditto
dp_("domainname", "context", "key")
ds_("domainname", "context|key")
dnp_("domainname", "context", "string", "strings")
dns_("domainname", "context|string", "strings")
```

These are helper methods so you don't need to write:

```Ruby
FastGettext.with_domain("domainname") { _("string") }
```

It is useful in Rails plugins in the views for example. The second set of
functions are D functions which search for string in _all_ domains. If there
are multiple translations in different domains, it returns them in random
order (depends on the Ruby hash implementation).

```Ruby
extend FastGettext::TranslationMultidomain

D_("string") # finds 'string' in any domain
Dn_("string", "strings", 1) # ditto
Dp_("context", "key")
Ds_("context|key")
Dnp_("context", "string", "strings")
Dns_("context|string", "strings")
```

Alternatively you can use [merge repository](https://github.com/grosser/fast_gettext#merge) to achieve the same behavior.

#### Block defaults

All the translation methods (including MultiDomain) support a block default, a feature not provided by ruby-gettext.  When a translation is
not found, if a block is provided the block is always returned. Otherwise, a key is returned. Methods doing pluralization will attempt a simple translation of alternate keys.

```ruby
_('not-found'){ "alternative default" } == alternate default
```

This block default is useful when the default is a very long passage of text that wouldn't make a useful key. You can also instrument logging not found keys.

```ruby
_('terms-and-conditions'){
  load_terms_and_conditions
  request_terms_and_conditions_translation_from_legal
}

# Override _ with logging
def _(key, &block)
  result = gettext(key){ nil } # nil returned when not found
  log_missing_translation_key(key) if result.nil?
  result || (block ? block.call : key)
end
```


FAQ
===
 - [Problems with ActiveRecord messages?](http://wiki.github.com/grosser/fast_gettext/activerecord)
 - [Iconv require error in 1.9.2](http://exceptionz.wordpress.com/2010/02/03/how-to-fix-the-iconv-require-error-in-ruby-1-9)


Authors
=======
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
 - [Tomas Strachota](https://github.com/tstrachota)
 - [Martin Meier](https://github.com/mameier)
 - [morcoteg](https://github.com/morcoteg)
 - [Daniel Schepers](https://github.com/tall-dan)
 - [Robert Graff](https://github.com/rgraff)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT, some vendor parts under the same license terms as Ruby (see headers)<br/>
[![CI](https://github.com/grosser/fast_gettext/actions/workflows/actions.yml/badge.svg)](https://github.com/grosser/fast_gettext/actions/workflows/actions.yml)
