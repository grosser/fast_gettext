class TranslationText < ActiveRecord::Base
  belongs_to :translation_key, :class_name => 'TranslationKey'
  validates_presence_of :locale
  validates_uniqueness_of :locale, :scope=>:translation_key_id
  attr_accessible :text, :locale, :translation_key, :translation_key_id if ActiveRecord::VERSION::MAJOR == 3 || defined?(ProtectedAttributes)
  after_update :expire_cache

  protected

  def expire_cache
    FastGettext.expire_cache_for(translation_key.key)
  end
end
