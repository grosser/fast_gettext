module FastGettext
  module TranslationRepository
    # Responsibility:
    #  - base for all repositories
    #  - fallback as empty repository, that cannot translate anything but does not crash
    class Base
      attr_accessor :locale
      def initialize(name,options={})
        @name = name
        @options = options
      end

      def available_locales
        []
      end

      def [](key)
        current_translations[key]
      end

      def plural(singular,plural,count)
        current_translations.plural(singular,plural,count)
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