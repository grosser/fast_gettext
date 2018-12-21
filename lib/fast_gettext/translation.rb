# frozen_string_literal: true

module FastGettext
  TRANSLATION_METHODS = [:_, :n_, :s_, :p_, :ns_, :np_].freeze
  NIL_BLOCK = -> { nil }

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

    # translate pluralized
    # some languages have up to 4 plural forms...
    # n_(singular, plural, plural form 2, ..., count)
    # n_('apple','apples',3)
    def n_(*keys, count)
      translations = FastGettext.cached_plural_find(*keys)
      selected = FastGettext.pluralisation_rule.call(count)
      selected = (selected ? 1 : 0) unless selected.is_a? Numeric # convert booleans to numbers

      # If we have a translation return it
      result = translations[selected]
      return result if result

      # If we have a block always use it in place of a translation
      return yield if block_given?

      # Fall back to the best fit translated key if it's there
      _(keys[selected] || keys.last)
    end

    # translate with namespace
    # 'Car', 'Tire' -> Tire if no translation could be found
    # p_('Car', 'Tire') == s_('Car|Tire')
    def p_(namespace, key, separator = nil)
      msgid = "#{namespace}#{separator || CONTEXT_SEPARATOR}#{key}"

      translation = FastGettext.cached_find(msgid)
      return translation if translation

      block_given? ? yield : key
    end

    # translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(key, separator = nil)
      translation = FastGettext.cached_find(key)
      return translation if translation

      block_given? ? yield : key.split(separator || NAMESPACE_SEPARATOR).last
    end

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

    # translate pluralized with context
    def np_(context, plural_one, *args, separator: nil)
      nargs = ["#{context}#{separator || CONTEXT_SEPARATOR}#{plural_one}"] + args
      translation = n_(*nargs, &NIL_BLOCK)
      return translation if translation

      return yield if block_given?

      n_(plural_one, *args)
    end
  end

  module TranslationAliased
    include Translation
    TRANSLATION_METHODS.each { |m| alias_method "#{m.to_s.delete('_')}gettext", m }
  end

  # this module should be included for multi-domain support
  module TranslationMultidomain
    include Translation

    # gettext functions to translate in the context of given domain
    TRANSLATION_METHODS.each do |method|
      eval <<-RUBY, nil, __FILE__, __LINE__ + 1 # rubocop:disable Security/Eval
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
