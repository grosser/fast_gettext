class FastGettext::TranslationRepository::DB::TranslationKey < ActiveRecord::Base
  has_many :translations, :class_name=>'TranslationText'
  validates_uniqueness_of :key
  validates_presence_of :key

  # TODO this should not be necessary, but
  # TranslationKey.respond_to? :available_locales
  # returns true even if this is not defined...
  def self.available_locales
    []
  end
end