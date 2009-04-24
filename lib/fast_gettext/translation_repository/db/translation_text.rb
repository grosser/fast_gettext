class FastGettext::TranslationRepository::DB::TranslationText < ActiveRecord::Base
  belongs_to :key, :class_name=>'TranslationKey'
  validates_presence_of :locale, :text
  validates_uniqueness_of :locale, :scope=>:translation_key_id
end