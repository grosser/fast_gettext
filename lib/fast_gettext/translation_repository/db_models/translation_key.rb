module FastGettext::TranslationRepository
  module DBModels
    class TranslationKey < ActiveRecord::Base
      has_many :translations, :class_name=>'TranslationText'
      validates_uniqueness_of :key
      validates_presence_of :key

      def self.translation(key, locale)
        return unless translation_key = find_by_key(key)
        return unless translation_text = translation_key.translations.find_by_locale(locale)
        translation_text.text
      end
    end
  end
end