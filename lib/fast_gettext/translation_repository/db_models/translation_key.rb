module FastGettext::TranslationRepository
  module DbModels
    class TranslationKey < ActiveRecord::Base
      has_many :translations, :class_name=>'TranslationText'
      accepts_nested_attributes_for :translations, :allow_destroy => true
      
      validates_uniqueness_of :key
      validates_presence_of :key

      def self.translation(key, locale)
        return unless translation_key = find_by_key(key)
        return unless translation_text = translation_key.translations.find_by_locale(locale)
        translation_text.text
      end

      def self.available_locales
        @@available_locales ||= TranslationText.count(:group=>:locale).keys.sort
      end

      # get polymorphic_url FastGettext::... namespace free
      # !! copied in translation_text.rb
      def self.name
        'TranslationKey'
      end

      def self.model_name
        if defined? ActiveSupport::ModelName # Rails 2
          ActiveSupport::ModelName.new(name)
        elsif defined? ActiveModel::Name # Rails 3
          ActiveModel::Name.new(self)
        else # Fallback
          name
        end
      end
    end
  end
end
