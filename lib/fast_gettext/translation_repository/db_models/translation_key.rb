class TranslationKey < ActiveRecord::Base
  has_many :translations, :class_name => 'TranslationText', :dependent => :destroy

  accepts_nested_attributes_for :translations, :allow_destroy => true

  validates_uniqueness_of :key
  validates_presence_of :key

  attr_accessible :key, :translations, :translations_attributes if ActiveRecord::VERSION::MAJOR == 3 || defined?(ProtectedAttributes)

  before_save :normalize_newlines

  def self.translation(key, locale)
    return unless translation_key = find_by_key(newline_normalize(key))
    return unless translation_text = translation_key.translations.find_by_locale(locale)
    translation_text.text
  end

  def self.available_locales
    @@available_locales ||= begin
      if ActiveRecord::VERSION::MAJOR >= 3
        TranslationText.group(:locale).count
      else
        TranslationText.count(:group=>:locale)
      end.keys.sort
    end
  end

  protected

  def self.newline_normalize(s)
    s.to_s.gsub("\r\n", "\n")
  end

  def normalize_newlines
    self.key = self.class.newline_normalize(key)
  end
end
