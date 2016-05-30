require 'fast_gettext/translation_repository/base'
module FastGettext
  module TranslationRepository
     # Responsibility:
    #  - find and store mo files
    #  - provide access to translations in mo files
    class Mo < Base
      def initialize(name,options={})
        super
        @eager_load = options.fetch(:eager_load, false)
        reload
      end

      def available_locales
        @files.keys
      end

      def pluralisation_rule
        current_translations.pluralisation_rule
      end

      def reload
        find_and_store_files(@name, @options)
        super
      end

      protected

      def find_and_store_files(name,options)
        # parse all .mo files with the right name, that sit in locale/LC_MESSAGES folders
        find_files_in_locale_folders(File.join('LC_MESSAGES',"#{name}.mo"), options[:path]) do |locale,file|
          MoFile.new(file, eager_load: @eager_load)
        end
      end

      def current_translations
        @files[FastGettext.locale] || MoFile.empty
      end
    end
  end
end
