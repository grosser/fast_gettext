# frozen_string_literal: true

module FastGettext
  # this module should be included
  # Responsibility:
  #  - direct translation queries to the current repository
  #  - handle untranslated values
  #  - understand / enforce namespaces
  #  - decide which plural form is used
  module Translation
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
    include Translation

    # make it usable in class definition, e.g.
    # class Y
    #   include FastGettext::TranslationMultidomain
    #   @@x = d_('domain', 'y')
    # end
    def self.included(klas) #:nodoc:
      klas.extend self
    end

    # gettext functions to translate in the context of given domain
    [:_, :n_, :s_, :p_, :ns_, :np_].each do |method|
      eval <<-RUBY, nil, __FILE__, __LINE__ +1
        def d#{method}(domain, *args, &block)
          FastGettext.with_domain(domain) { #{method}(*args, &block) }
        end
      RUBY
    end

    # gettext functions to translate in the context of any domain
    # (note: if multiple domains contains key, first translation is returned)
    def D_(key)
      FastGettext.translation_repositories.each_key do |domain|
        result = d_(domain, key) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : key
    end

    def Dn_(*keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = dn_(domain, *keys) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : _(FastGettext::PluralizationHelper.fallback(*keys))
    end

    def Ds_(key, separator = nil)
      FastGettext.translation_repositories.each_key do |domain|
        result = ds_(domain, key, separator) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : key.split(separator || NAMESPACE_SEPARATOR).last
    end

    def Dp_(namespace, key, separator = nil)
      FastGettext.translation_repositories.each_key do |domain|
        result = dp_(domain, namespace, key, separator) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : key
    end

    def Dns_(*keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = dns_(domain, *keys) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : s_(FastGettext::PluralizationHelper.fallback(*keys))
    end

    def Dnp_(context, *keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = dnp_(domain, context, *keys) { nil }
        return result unless result.nil?
      end
      block_given? ? yield : p_(context, FastGettext::PluralizationHelper.fallback(*keys))
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
