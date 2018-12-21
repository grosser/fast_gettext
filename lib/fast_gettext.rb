# frozen_string_literal: true

require 'fast_gettext/mo_file'
require 'fast_gettext/storage'
require 'fast_gettext/translation'
require 'fast_gettext/translation_repository'
require 'fast_gettext/vendor/string'
require 'fast_gettext/version'

module FastGettext
  extend FastGettext::Storage
  extend FastGettext::Translation

  LOCALE_REX = /^[a-z]{2,3}$|^[a-z]{2,3}_[A-Z]{2,3}$/.freeze
  NAMESPACE_SEPARATOR = '|'
  CONTEXT_SEPARATOR = "\004"

  # helper block for changing domains
  def self.with_domain(domain)
    old_domain = FastGettext.text_domain
    FastGettext.text_domain = domain
    yield
  ensure
    FastGettext.text_domain = old_domain
  end

  def self.add_text_domain(name, options)
    translation_repositories[name] = TranslationRepository.build(name, options)
  end

  # some repositories know where to store their locales
  def self.locale_path
    translation_repositories[text_domain].instance_variable_get(:@options)[:path]
  end
end
