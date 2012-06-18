require 'fast_gettext/mo_file'
module FastGettext
  # Responsibility:
  #  - abstract po files for Po Repository
  class PoFile
    def self.to_mo_file(file, options={})
      require 'fast_gettext/vendor/poparser'
      parser = FastGettext::GetText::PoParser.new

      warn ":ignore_obsolete is no longer supported, use :report_warning" if options.key? :ignore_obsolete
      parser.ignore_fuzzy = options[:ignore_fuzzy]
      parser.report_warning = options.fetch(:report_warning, true)

      mo_file = FastGettext::GetText::MOFile.new
      parser.parse(File.read(file), mo_file)
      MoFile.new(mo_file)
    end
  end
end
