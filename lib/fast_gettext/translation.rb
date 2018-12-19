# frozen_string_literal: true

module FastGettext
  # this module should be included
  # Responsibility:
  #  - direct translation queries to the current repository
  #  - handle untranslated values
  #  - understand / enforce namespaces
  #  - decide which plural form is used
  module Translation
    NIL_BLOCK = -> { nil }

    def _(key)
      FastGettext.cached_find(key) || (block_given? ? yield : key)
    end
    alias gettext _

    # translate pluralized
    # some languages have up to 4 plural forms...
    # n_(singular, plural, plural form 2, ..., count)
    # n_('apple','apples',3)
    def n_(*keys, count, &block)
      translations = FastGettext.cached_plural_find(*keys)
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

    # translate pluralized with separator
    def ns_(*args)
      translation = n_(*args, &NIL_BLOCK)
      return translation if translation

      return yield if block_given?

      n_(*args).split(NAMESPACE_SEPARATOR).last
    end
    alias nsgettext ns_

    # translate pluralized with context
    def np_(context, plural_one, *args, separator: nil)
      nargs = ["#{context}#{separator || CONTEXT_SEPARATOR}#{plural_one}"] + args
      result = n_(*nargs, &NIL_BLOCK)
      return result if result

      return yield if block_given?

      n_(plural_one, *args)
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
        # translate in given domain
        def d#{method}(domain, *args, &block)
          FastGettext.with_domain(domain) { #{method}(*args, &block) }
        end

        # translate with whatever domain finds a translation
        def D#{method}(*args, &block)
          repos = FastGettext.translation_repositories
          last = repos.size - 1
          repos.each_key.each_with_index do |domain, i|
            if i == last
              return d#{method}(domain, *args, &block)
            else
              result = d#{method}(domain, *args, &NIL_BLOCK)
              return result if result
            end
          end
        end
      RUBY
    end
  end
end
