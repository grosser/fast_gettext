require 'fast_gettext/vendor/mofile'
module FastGettext
  # Responsibility:
  #  - abstract mo files for Mo Repository
  class MoFile
    PLURAL_SEPERATOR = "\000"

    # file => path or FastGettext::GetText::MOFile
    def initialize(file, options={})
      @filename = file
      load_data if options[:eager_load]
    end

    def [](key)
      data[key]
    end

    #returns the plural forms or all singular translations that where found
    # Car, Cars => [Auto,Autos] or []
    def plural(*msgids)
      split_plurals(self[msgids*PLURAL_SEPERATOR].to_s)
    end

    def pluralisation_rule
      #gettext uses 0 as default rule, which would turn off all pluralisation, very clever...
      #additionally parsing fails when directly accessing po files, so this line was taken from gettext/mofile
      (data['']||'').split("\n").each do |line|
        return lambda{|n|eval($2)} if /^Plural-Forms:\s*nplurals\s*\=\s*(\d*);\s*plural\s*\=\s*([^;]*)\n?/ =~ line
      end
      nil
    end

    def self.empty
      MoFile.new(File.join(File.dirname(__FILE__),'vendor','empty.mo'))
    end

    private

    def data
      load_data if @data.nil?
      @data
    end

    def load_data
      @data = if @filename.is_a? FastGettext::GetText::MOFile
        @filename
      else
        FastGettext::GetText::MOFile.open(@filename, "UTF-8")
      end
      make_singular_and_plural_available
    end

    #(if plural==singular, prefer singular)
    def make_singular_and_plural_available
      data = {}
      @data.each do |key,translation|
        next unless key.include? PLURAL_SEPERATOR
        singular, plural = split_plurals(key)
        translation = split_plurals(translation)
        data[singular] ||= translation[0]
        data[plural] ||= translation[1]
      end
      @data.merge!(data){|key,old,new| old}
    end

    def split_plurals(singular_plural)
      singular_plural.split(PLURAL_SEPERATOR)
    end
  end
end
