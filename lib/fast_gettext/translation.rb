module FastGettext
  module Translation
    extend self
    
    def _(translate)
      FastGettext.current_translations[translate] || translate
    end

    #translate pluralized
    def n_(singular,plural,count)
      if translation = FastGettext.current_translations.plural(singular,plural,count)
        translation
      else
        count > 1 ? plural : singular
      end
    end

    #translate, but discard namespace if nothing was found
    # Car|Tire -> Tire if no translation could be found
    def s_(translate,seperator=nil)
      if translation = FastGettext.current_translations[translate]
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