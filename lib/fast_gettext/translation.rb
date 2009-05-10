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

    def _(translate)
      found = FastGettext.current_cache[translate] and return found
      FastGettext.current_cache[translate] = FastGettext.current_repository[translate] || translate
    end

    #translate pluralized
    # some languages have up to 4 plural forms...
    # n_(singular, plural, plural form 2, ..., count)
    # n_('apple','apples',3)
    def n_(*msgids)
      count = msgids.pop
      repo = FastGettext.current_repository

      translations = repo.plural(*msgids)
      selected = FastGettext.pluralisation_rule.call(count)
      selected = selected ? 1 : 0 unless selected.is_a? Numeric #convert booleans to numbers
      translations[selected] || msgids[selected] || msgids.last
    end

    #translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(key,seperator=nil)
      if translation = current_cache[key] || FastGettext.current_repository[key]
        translation
      else
        key.split(seperator||NAMESPACE_SEPERATOR).last
      end
    end

    #tell gettext: this string need translation (will be found during parsing)
    def N_(translate)
      translate
    end

    #tell gettext: this string need translation (will be found during parsing)
    def Nn_(*msgids)
      msgids
    end
  end
end