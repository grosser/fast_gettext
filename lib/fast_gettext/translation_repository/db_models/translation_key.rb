module FastGettext::TranslationRepository
  module DBModels
    class TranslationKey < ActiveRecord::Base
      has_many :translations, :class_name=>'TranslationText'
      validates_uniqueness_of :key
      validates_presence_of :key
    end
  end
end