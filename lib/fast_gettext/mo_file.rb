require File.join(File.dirname(__FILE__),'..','..','vendor','mofile')
module FastGettext
  # Responsibility:
  #  - abstract mo files for Mo Repository
  class MoFile
    PLURAL_SEPERATOR = "\000"

    # file => path or FastGettext::GetText::MOFile
    def initialize(file)
      if file.is_a? FastGettext::GetText::MOFile
        @data = file
      else
        @data = FastGettext::GetText::MOFile.open(file, "UTF-8")
      end
      make_singular_and_plural_available
    end

    def [](key)
      @data[key]
    end

    def plural(singular,plural,count)
      translations = plural_translations(singular,plural)

      if count == 1
        translations[0] || self[singular]
      else
        translations[1] || self[plural]
      end
    end

    def self.empty
      MoFile.new(File.join(File.dirname(__FILE__),'..','..','vendor','empty.mo'))
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