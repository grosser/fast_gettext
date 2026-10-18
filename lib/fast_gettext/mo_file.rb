# frozen_string_literal: true

require 'fast_gettext/vendor/mofile'
module FastGettext
  # Responsibility:
  #  - abstract mo files for Mo Repository
  class MoFile
    PLURAL_SEPARATOR = "\000"
    CONTEXT_SEPARATOR = "\004"

    # file => path or FastGettext::GetText::MOFile
    def initialize(file, options = {})
      @filename = file
      @data = nil
      @pluralisation_rule = nil
      load_data if options[:eager_load]
    end

    def [](key)
      data[key]
    end

    # returns the plural forms or all singular translations that where found
    # Car, Cars => [Auto,Autos] or []
    def plural(*msgids)
      split_plurals(self[msgids * PLURAL_SEPARATOR].to_s)
    end

    # n_() asks for this on every call: read from the header and compiled the
    # first time, then kept (false: the file has none).
    def pluralisation_rule
      rule = @pluralisation_rule
      return rule || nil unless rule.nil?

      rule = read_pluralisation_rule || false
      @pluralisation_rule = rule unless frozen?
      rule || nil
    end

    def data
      load_data if @data.nil?
      @data
    end

    def self.empty
      @empty ||= MoFile.new(File.join(__dir__, 'vendor', 'empty.mo'), eager_load: true).tap(&:pluralisation_rule).freeze
    end

    private

    def read_pluralisation_rule
      # gettext uses 0 as default rule, which would turn off all pluralisation, very clever...
      # additionally parsing fails when directly accessing po files, so this line was taken from gettext/mofile
      (data[''] || '').split("\n").each do |line|
        if /^Plural-Forms:\s*nplurals\s*=\s*(\d*);\s*plural\s*=\s*([^;]*)\n?/ =~ line
          return eval("->(n) { #{$2} }", nil, __FILE__, __LINE__) # rubocop:disable Security/Eval
        end
      end
      nil
    end

    def load_data
      @data =
        if @filename.is_a? FastGettext::GetText::MOFile
          @filename
        else
          FastGettext::GetText::MOFile.open(@filename, "UTF-8")
        end
      make_singular_and_plural_available
    end

    # (if plural==singular, prefer singular)
    def make_singular_and_plural_available
      data = {}
      @data.each do |key, translation|
        next unless key.include? PLURAL_SEPARATOR

        singular, plural = split_plurals(key)
        translation = split_plurals(translation)
        data[singular] ||= translation[0]
        data[plural] ||= translation[1]
      end
      @data.merge!(data) { |_key, old, _new| old }
    end

    def split_plurals(singular_plural)
      singular_plural.split(PLURAL_SEPARATOR)
    end
  end
end
