module FastGettext::TranslationRepository
  module DbModels
    class TranslationText < ActiveRecord::Base
      belongs_to :key, :class_name=>'TranslationKey'
      validates_presence_of :locale
      validates_uniqueness_of :locale, :scope=>:translation_key_id

      # get polymorphic_url FastGettext::... namespace free
      # !! copied in translation_key.rb
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