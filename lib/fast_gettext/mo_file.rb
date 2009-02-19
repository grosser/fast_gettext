require File.join(File.dirname(__FILE__),'..','..','vendor','mofile')
module FastGettext
  class MoFile
    PLURAL_SEPERATOR = "\000"

    def initialize(file)
      @data = GetText::MOFile.open(file, "UTF-8")
      make_singular_and_plural_available
    end

    def [](key)
      @data[key]
    end

    def plural(singular,plural,count)
      translations = plural_translations(singular,plural)

      if count > 1
        translations[1] || self[plural]
      else
        translations[0] || self[singular]
      end
    end

    private

    #(if plural==singular, prefer singular)
    def make_singular_and_plural_available
      @data.each do |key,translation|
        next unless key.include? PLURAL_SEPERATOR
        singular, plural = split_plurals(key)
        translation = split_plurals(translation)
        @data[singular] ||= translation[0]
        @data[plural] ||= translation[1]
      end
    end

    def split_plurals(singular_plural)
      singular_plural.split(PLURAL_SEPERATOR,2)
    end

    # Car, Cars => [Auto,Autos] or []
    def plural_translations(singular,plural)
      plurals = self[singular+PLURAL_SEPERATOR+plural]
      if plurals then split_plurals(plurals) else [] end
    end
  end
end