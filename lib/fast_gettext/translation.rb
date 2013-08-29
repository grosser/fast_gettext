module FastGettext
  # this module should be included
  # Responsibility:
  #  - direct translation queries to the current repository
  #  - handle untranslated values
  #  - understand / enforce namespaces
  #  - decide which plural form is used
  module Translation
    extend self

    #make it usable in class definition, e.g.
    # class Y
    #   include FastGettext::Translation
    #   @@x = _('y')
    # end
    def self.included(klas)  #:nodoc:
      klas.extend self
    end

    def _(key, &block)
      FastGettext.cached_find(key) or (block ? block.call : key)
    end

    #translate pluralized
    # some languages have up to 4 plural forms...
    # n_(singular, plural, plural form 2, ..., count)
    # n_('apple','apples',3)
    def n_(*keys, &block)
      count = keys.pop
      translations = FastGettext.cached_plural_find(*keys)

      selected = FastGettext.pluralisation_rule.call(count)
      selected = (selected ? 1 : 0) unless selected.is_a? Numeric #convert booleans to numbers

      result = translations[selected]
      if result
        result
      elsif keys[selected]
        _(keys[selected])
      else
        block ? block.call : keys.last
      end
    end

    #translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(key, separator=nil, &block)
      translation = FastGettext.cached_find(key) and return translation
      block ? block.call : key.split(separator||NAMESPACE_SEPARATOR).last
    end

    #tell gettext: this string need translation (will be found during parsing)
    def N_(translate)
      translate
    end

    #tell gettext: this string need translation (will be found during parsing)
    def Nn_(*keys)
      keys
    end

    def ns_(*args, &block)
      translation = n_(*args, &block)
      # block is called once again to compare result
      block && translation == block.call ? translation : translation.split(NAMESPACE_SEPARATOR).last
    end
  end

  # this module should be included for multi-domain support
  module TranslationMultidomain
    extend self

    #make it usable in class definition, e.g.
    # class Y
    #   include FastGettext::TranslationMultidomain
    #   @@x = d_('domain', 'y')
    # end
    def self.included(klas)  #:nodoc:
      klas.extend self
    end

    # helper block for changing domains
    def _in_domain domain
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

    def ds_(domain, key, separator=nil, &block)
      _in_domain domain do
        FastGettext::Translation.s_(key, separator, &block)
      end
    end

    def dns_(domain, *keys, &block)
      _in_domain domain do
        FastGettext::Translation.ns_(*keys, &block)
      end
    end

    # gettext functions to translate in the context of any domain
    # (note: if mutiple domains contains key, random translation is returned)
    def D_(key)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.d_(domain, key) {nil}
        return result unless result.nil?
      end
      key
    end

    def Dn_(*keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.dn_(domain, *keys) {nil}
        return result unless result.nil?
      end
      keys[-3].split(keys[-2]||NAMESPACE_SEPARATOR).last
    end

    def Ds_(key, separator=nil)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.ds_(domain, key, separator) {nil}
        return result unless result.nil?
      end
      key.split(separator||NAMESPACE_SEPARATOR).last
    end

    def Dns_(*keys)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.dns_(domain, *keys) {nil}
        return result unless result.nil?
      end
      keys[-2].split(NAMESPACE_SEPARATOR).last
    end
  end
end
