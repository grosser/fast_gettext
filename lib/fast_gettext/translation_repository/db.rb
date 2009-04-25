require 'active_record'
module FastGettext
  module TranslationRepository
    # Responsibility:
    #  - provide access to translations in database through a database abstraction
    #
    #  Options:
    #   :model => Model that represents your keys
    #   you can either use the models supplied under db/, extend them or build your own
    #   only constraints:
    #     key: find_by_key, translations
    #     translation: text, locale
    class DB
      def initialize(name,options={})
        @model = options[:model]
      end

      @@seperator = '||||' # string that seperates multiple plurals
      def self.seperator=(sep);@@seperator = sep;end
      def self.seperator;@@seperator;end

      def available_locales
        if @model.respond_to? :available_locales
          @model.available_locales || []
        else
          []
        end
      end

      def pluralisation_rule
        if @model.respond_to? :pluralsation_rule
          @model.pluralsation_rule
        else
          nil
        end
      end

      def [](key)
        translation(key)
      end

      def plural(*args)
        if translation = translation(args*self.class.seperator)
          translation.to_s.split(self.class.seperator)
        else
          []
        end
      end

      def self.require_models
        require 'fast_gettext/translation_repository/db_models/translation_key'
        require 'fast_gettext/translation_repository/db_models/translation_text'
        FastGettext::TranslationRepository::DBModels
      end

      protected

      def translation(key)
        return unless key = @model.find_by_key(key)
        return unless translation = key.translations.find_by_locale(FastGettext.locale)
        translation.text
      end
    end
  end
end