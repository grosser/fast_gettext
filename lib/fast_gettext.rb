# frozen_string_literal: true

require 'fast_gettext/mo_file'
require 'fast_gettext/storage'
require 'fast_gettext/translation'
require 'fast_gettext/translation_repository'
require 'fast_gettext/vendor/string'
require 'fast_gettext/version'

module FastGettext
  include FastGettext::Storage
  extend self # rubocop:disable Style/ModuleFunction

  LOCALE_REX =  /^[a-z]{2,3}$|^[a-z]{2,3}_[A-Z]{2,3}$/.freeze
  NAMESPACE_SEPARATOR = '|'
  CONTEXT_SEPARATOR = "\u0004"

  # users should not include FastGettext, since this would contaminate their namespace
  # rather use
  # FastGettext.locale = ..
  # FastGettext.text_domain = ..
  # and
  # include FastGettext::Translation
  FastGettext::Translation.public_instance_methods.each do |method|
    define_method method do |*args|
      Translation.send(method, *args)
    end
  end

  def add_text_domain(name, options)
    translation_repositories[name] = TranslationRepository.build(name, options)
  end

  # some repositories know where to store their locales
  def locale_path
    translation_repositories[text_domain].instance_variable_get(:@options)[:path]
  end
end
