# frozen_string_literal: true

module FastGettext
  # this module should be included
  # Responsibility:
  #  - direct translation queries to the current repository
  #  - handle untranslated values
  #  - understand / enforce namespaces
  #  - decide which plural form is used
  module Translation
    extend self # rubocop:disable Style/ModuleFunction

    # make it usable in class definition, e.g.
    # class Y
    #   include FastGettext::Translation
    #   @@x = _('y')
    # end
    def self.included(klas)
      klas.extend self
    end

    def _(key)
      FastGettext.cached_find(key) || (block_given? ? yield : key)
    end
    alias gettext _

    # translate pluralized
    # some languages have up to 4 plural forms...
    # n_(singular, plural, plural form 2, ..., count)
    # n_('apple','apples',3)
    def n_(*keys, &block)
      count = keys.pop
      translations = FastGettext.cached_plural_find(*keys)
      FastGettext::PluralizationHelper.pluralize(count, keys, translations, &block)
    end
    alias ngettext n_

    # translate with namespace, use namespace to find key
    # 'Car','Tire' -> Tire if no translation could be found
    # p_('Car','Tire') <=> s_('Car|Tire')
    def p_(namespace, key, separator = nil)
      msgid = "#{namespace}#{separator || CONTEXT_SEPARATOR}#{key}"
      FastGettext.cached_find(msgid) || (block_given? ? yield : key)
    end
    alias pgettext p_

    # translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(key, separator = nil)
      if translation = FastGettext.cached_find(key)
        return translation
      end

      block_given? ? yield : key.split(separator || NAMESPACE_SEPARATOR).last
    end
    alias sgettext s_

    # tell gettext: this string need translation (will be found during parsing)
    def N_(translate)
      translate
    end

    # tell gettext: this string need translation (will be found during parsing)
    def Nn_(*keys)
      keys
    end

    def ns_(*keys)
      translation = n_(*keys) { nil }
      return translation.split(NAMESPACE_SEPARATOR).last if translation

      return yield if block_given?

      FastGettext::PluralizationHelper.fallback(*keys).split(NAMESPACE_SEPARATOR).last
    end
    alias nsgettext ns_

    def np_(context, *keys, separator: nil)
      nargs = ["#{context}#{separator || CONTEXT_SEPARATOR}#{keys[0]}"] + keys[1..-1]
      result = n_(*nargs) { nil }
      return result if result
      return yield if block_given?

      FastGettext::PluralizationHelper.fallback(*keys)
    end
    alias npgettext np_
  end

  # this module should be included for multi-domain support
  module TranslationMultidomain
    extend self # rubocop:disable Style/ModuleFunction

    # make it usable in class definition, e.g.
    # class Y
    #   include FastGettext::TranslationMultidomain
    #   @@x = d_('domain', 'y')
    # end
    def self.included(klas) #:nodoc:
      klas.extend self
    end

    # helper block for changing domains
    def _in_domain(domain)
      old_domain = FastGettext.text_domain
      FastGettext.text_domain = domain
      yield if block_given?
    ensure
      FastGettext.text_domain = old_domain
    end

    # gettext functions to translate in the context of given domain
    def d_(domain, key, &block)
      _in_domain domain do
        FastGettext::Translation._(key, &block)
      end
    end

    def dn_(domain, *keys, &block)
      _in_domain domain do
        FastGettext::Translation.n_(*keys, &block)
      end
    end

    def ds_(domain, key, separator = nil, &block)
      _in_domain domain do
        FastGettext::Translation.s_(key, separator, &block)
      end
    end

    def dp_(domain, namespace, key, separator = nil, &block)
      _in_domain domain do
        FastGettext::Translation.p_(namespace, key, separator, &block)
      end
    end

    def dns_(domain, *keys, &block)
      _in_domain domain do
        FastGettext::Translation.ns_(*keys, &block)
      end
    end

    def dnp_(domain, context, key, *args, &block)
      _in_domain domain do
        FastGettext::Translation.np_(context, key, *args, &block)
      end
    end

    # gettext functions to translate in the context of any domain
    # (note: if mutiple domains contains key, random translation is returned)
    def D_(key)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.d_(domain, key) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : key
    end

    def Dn_(*keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.dn_(domain, *keys) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : FastGettext._(FastGettext::PluralizationHelper.fallback(*keys))
    end

    def Ds_(key, separator = nil)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.ds_(domain, key, separator) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : key.split(separator || NAMESPACE_SEPARATOR).last
    end

    def Dp_(namespace, key, separator = nil)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.dp_(domain, namespace, key, separator) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : key
    end

    def Dns_(*keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.dns_(domain, *keys) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : FastGettext.s_(FastGettext::PluralizationHelper.fallback(*keys))
    end

    def Dnp_(context, *keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.dnp_(domain, context, *keys) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : FastGettext.p_(context, FastGettext::PluralizationHelper.fallback(*keys))
    end
  end

  module PluralizationHelper
    def self.fallback(*keys)
      count = keys.pop
      pluralize(count, keys, [])
    end

    def self.pluralize(count, keys, translations)
      selected = FastGettext.pluralisation_rule.call(count)
      selected = (selected ? 1 : 0) unless selected.is_a? Numeric # convert booleans to numbers

      # If we have a translation return it
      result = translations[selected]
      return result if result

      # If we have a block always use it in place of a translation
      return yield if block_given?

      # Fall back to the best fit translated key if it's there
      FastGettext._(keys[selected] || keys.last)
    end
  end
end
