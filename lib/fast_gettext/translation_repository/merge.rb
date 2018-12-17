# frozen_string_literal: true

require 'fast_gettext/translation_repository/po'

module FastGettext
  module TranslationRepository
    # Responsibility:
    #  - merge data from multiple repositories into one hash structure
    #  - can be used instead of searching for translations in multiple domains
    #  - requires reload when current locale is changed
    class Merge < Base
      def initialize(name, options = {})
        clear
        super(name, options)
        options.fetch(:chain, []).each do |repo|
          add_repo(repo)
        end
      end

      def available_locales
        @repositories.flat_map(&:available_locales).uniq
      end

      def pluralisation_rule
        @repositories.each do |r|
          if result = r.pluralisation_rule
            return result
          end
        end
        nil
      end

      def plural(*keys)
        @repositories.each do |r|
          result = r.plural(*keys)
          return result unless result.compact.empty?
        end
        []
      end

      def reload
        @data = {}
        @repositories.each do |r|
          r.reload
          load_repo(r)
        end
        super
      end

      def add_repo(repo)
        raise "Unsupported repository" unless repo_supported?(repo)

        @repositories << repo
        load_repo(repo)
        true
      end

      def [](key)
        @data[key]
      end

      def clear
        @repositories = []
        @data = {}
      end

      protected

      def repo_supported?(repo)
        repo.respond_to?(:all_translations)
      end

      def load_repo(repo)
        @data = repo.all_translations.merge(@data)
      end
    end
  end
end
