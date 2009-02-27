module FastGettext
  # this module should be included
  # Responsibility:
  #  - direct translation queries to the current repository
  #  - handle untranslated values
  #  - understand / enforce namespaces
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
    def n_(singular,plural,count)
      if translation = FastGettext.current_repository.plural(singular,plural,count)
        translation
      else
        #TODO remove this repeated logic, e.g. return :plural / :singular or raise an exception ?
        count == 1 ? singular : plural
      end
    end

    #translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(translate,seperator=nil)
      if translation = FastGettext.current_repository[translate]
        translation
      else
        translate.split(seperator||NAMESPACE_SEPERATOR).last
      end
    end

    #tell gettext: this string need translation (will be found during parsing)
    def N_(translate)
      translate
    end

    #tell gettext: this string need translation (will be found during parsing)
    def Nn_(singular,plural)
      [singular,plural]
    end
  end
end