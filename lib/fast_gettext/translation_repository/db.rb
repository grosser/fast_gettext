# frozen_string_literal: true

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
    class Db
      def initialize(_name, options = {})
        @model = options[:model]
      end

      @separator = '||||' # string that separates multiple plurals
      class << self
        attr_accessor :separator
      end

      def available_locales
        if @model.respond_to? :available_locales
          @model.available_locales || []
        else
          []
        end
      end

      def pluralisation_rule
        @model.pluralisation_rule if @model.respond_to? :pluralisation_rule
      end

      def [](key)
        @model.translation(key, FastGettext.locale)
      end

      def plural(*args)
        if translation = @model.translation(args * self.class.separator, FastGettext.locale)
          translation.to_s.split(self.class.separator)
        else
          []
        end
      end

      def reload
        true
      end

      def self.require_models
        require 'active_record'
        folder = "fast_gettext/translation_repository/db_models"
        require "#{folder}/translation_key"
        require "#{folder}/translation_text"
        Module.new do
          def self.included(_base)
            puts "you no longer need to include the result of require_models"
          end
        end
      end
    end
  end
end
