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

    def _(key)
      FastGettext.cached_find(key) or (block_given? ? yield : key)
    end
    alias :gettext :_

    #translate pluralized
    # some languages have up to 4 plural forms...
    # n_(singular, plural, plural form 2, ..., count)
    # n_('apple','apples',3)
    def n_(*keys)
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
        block_given? ? yield : keys.last
      end
    end
    alias :ngettext :n_

    #translate with namespace, use namespace to find key
    # 'Car','Tire' -> Tire if no translation could be found
    # p_('Car','Tire') <=> s_('Car|Tire')
    def p_(namespace, key, separator=nil)
      msgid = "#{namespace}#{separator||CONTEXT_SEPARATOR}#{key}"
      FastGettext.cached_find(msgid) or (block_given? ? yield : key)
    end
    alias :pgettext :p_

    #translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(key, separator=nil)
      translation = FastGettext.cached_find(key) and return translation
      block_given? ? yield : key.split(separator||NAMESPACE_SEPARATOR).last
    end
    alias :sgettext :s_

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

      # block is called once again to compare result TODO: this is bad
      block && translation == block.call ? translation : translation.split(NAMESPACE_SEPARATOR).last
    end
    alias :nsgettext :ns_

    def np_(context, key, *args)
      options = (args.last.is_a? Hash) ? args.pop : {}
      nargs = ["#{context}#{options[:separator]||CONTEXT_SEPARATOR}#{key}"] + args
      n_(*nargs){nil} or (block_given? ? yield : key)
    end
    alias :npgettext :np_
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

    def ds_(domain, key, separator=nil, &block)
      _in_domain domain do
        FastGettext::Translation.s_(key, separator, &block)
      end
    end

    def dp_(domain, namespace, key, separator=nil, &block)
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

    def Dp_(namespace, key, separator=nil, &block)
      FastGettext.translation_repositories.each_key do |domain|
        result = FastGettext::TranslationMultidomain.dp_(domain, namespace, key, separator) {nil}
        return result unless result.nil?
      end
      block ? block.call : key
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
