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
      cached_find(key) or key
    end

    #translate pluralized
    # some languages have up to 4 plural forms...
    # n_(singular, plural, plural form 2, ..., count)
    # n_('apple','apples',3)
    def n_(*keys)
      count = keys.pop
      translations = cached_plural_find *keys
      selected = FastGettext.pluralisation_rule.call(count)
      selected = selected ? 1 : 0 unless selected.is_a? Numeric #convert booleans to numbers
      translations[selected] || keys[selected] || keys.last
    end

    #translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(key,seperator=nil)
      translation = cached_find(key) and return translation
      key.split(seperator||NAMESPACE_SEPERATOR).last
    end

    #tell gettext: this string need translation (will be found during parsing)
    def N_(translate)
      translate
    end

    #tell gettext: this string need translation (will be found during parsing)
    def Nn_(*keys)
      keys
    end

    private

    def cached_find(key)
      translation = FastGettext.current_cache[key]
      return translation if translation or translation == false #found or was not found before
      FastGettext.current_cache[key] = FastGettext.current_repository[key] || false
    end

    def cached_plural_find(*keys)
      key = '||||' + keys * '||||'
      translation = FastGettext.current_cache[key]
      return translation if translation or translation == false #found or was not found before
      FastGettext.current_cache[key] = FastGettext.current_repository.plural(*keys) || false
    end
  end
end