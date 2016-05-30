require 'fast_gettext/mo_file'
module FastGettext
  # Responsibility:
  #  - abstract po files for Po Repository
  class PoFile < MoFile
    def initialize(file, options={})
      @options = options
      super
    end

    def self.to_mo_file(file, options={})
      MoFile.new(parse_po_file(file, options))
    end

    protected

    def load_data
      @data = if @filename.is_a? FastGettext::GetText::MOFile
        @filename
      else
        FastGettext::PoFile.parse_po_file(@filename, @options)
      end
      make_singular_and_plural_available
    end

    def self.parse_po_file(file, options={})
      require 'fast_gettext/vendor/poparser'
      parser = FastGettext::GetText::PoParser.new

      warn ":ignore_obsolete is no longer supported, use :report_warning" if options.key? :ignore_obsolete
      parser.ignore_fuzzy = options[:ignore_fuzzy]
      parser.report_warning = options.fetch(:report_warning, true)

      mo_file = FastGettext::GetText::MOFile.new
      parser.parse(File.read(file), mo_file)
      mo_file
    end
  end
end
