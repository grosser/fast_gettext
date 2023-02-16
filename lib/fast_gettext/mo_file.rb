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

    def pluralisation_rule
      # gettext uses 0 as default rule, which would turn off all pluralisation, very clever...
      # additionally parsing fails when directly accessing po files, so this line was taken from gettext/mofile
      (data[''] || '').split("\n").each do |line|
        if /^Plural-Forms:\s*nplurals\s*\=\s*(\d*);\s*plural\s*\=\s*([^;]*)\n?/ =~ line
          return ->(n) do # rubocop:disable Lint/UnusedBlockArgument
            eval($2) # rubocop:disable Security/Eval
          end
        end
      end
      nil
    end

    def data
      load_data if @data.nil?
      @data
    end

    def self.empty
      @empty ||= MoFile.new(File.join(__dir__, 'vendor', 'empty.mo'), eager_load: true).freeze
    end

    private

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
