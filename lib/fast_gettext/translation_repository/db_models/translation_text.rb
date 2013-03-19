class TranslationText < ActiveRecord::Base
  belongs_to :translation_key, :class_name => 'TranslationKey'
  validates_presence_of :locale
  validates_uniqueness_of :locale, :scope=>:translation_key_id
  attr_accessible :text, :locale, :translation_key, :translation_key_id
  after_save :expire_cache

  protected

  def expire_cache
    FastGettext.expire_cache_for(translation_key.key) if translation_key.present?
  end
end
