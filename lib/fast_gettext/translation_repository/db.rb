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
          @model.available_locales
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
        translation = translation(key) and translation.text
      end

      def plural(*args)
        translation = translation(args*self.class.seperator)
        if translation
          translation.text.to_s.split(self.class.seperator)
        else
          []
        end
      end

      protected

      def translation(key)
        return unless key = @model.find_by_key(key)
        key.translations.find_by_locale(FastGettext.locale)
      end
    end
  end
end