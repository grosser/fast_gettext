module FastGettext
  module TranslationRepository
    # Responsibility:
    #  - base for all repositories
    #  - fallback as empty repository, that cannot translate anything but does not crash
    class Base
      attr_accessor :locale
      attr_writer :pluralisation_rule

      def initialize(name,options={})
        @name = name
        @options = options
      end

      def pluralisation_rule
        @pluralisation_rule || lambda{|n| n==1 ? 0 : 1}
      end

      def available_locales
        []
      end

      def [](key)
        current_translations[key]
      end

      def plural(*msgids)
        current_translations.plural(*msgids)
      end

      protected

      def current_translations
        MoFile.empty
      end

      def find_files_in_locale_folders(relative_file_path,path)
        path ||= "locale"
        raise "path #{path} cound not be found!" unless File.exist?(path)

        @files = {}
        Dir[File.join(path,'*')].each do |locale_folder|
          next unless File.basename(locale_folder) =~ LOCALE_REX
          file = File.join(locale_folder,relative_file_path)
          next unless File.exist? file
          locale = File.basename(locale_folder)
          @files[locale] = yield(locale,file)
        end
      end
    end
  end
end