# frozen_string_literal: true

require 'fast_gettext/translation_repository/base'
require 'yaml'

module FastGettext
  module TranslationRepository
    # Responsibility:
    #  - find and store yaml files
    #  - provide access to translations in yaml files
    class Yaml < Base
      def initialize(name, options = {})
        super
        reload
      end

      def available_locales
        @files.keys
      end

      def plural(*keys)
        ['one', 'other', 'plural2', 'plural3'].map do |name|
          self[yaml_dot_notation(keys.first, name)]
        end
      end

      def pluralisation_rule
        return unless rule = self['pluralisation_rule']

        ->(n) do # rubocop:disable Lint/UnusedBlockArgument n can be used from pluralisation_rule code
          eval(rule) # rubocop:disable Security/Eval TODO remove eval
        end
      end

      def reload
        find_and_store_files(@options)
        super
      end

      protected

      MAX_FIND_DEPTH = 10

      def find_and_store_files(options)
        @files = {}
        path = options[:path] || 'config/locales'
        Dir["#{path}/*.yml"].each do |yaml_file|
          # Only take into account the last dot separeted part of the file name,
          # excluding the extension file name
          # that is, we suppose it to be named `qq.yml` or `foo.qq.yml` where
          # `qq` stands for a locale name
          locale = File.basename(yaml_file, '.yml').split('.').last
          (@files[locale] ||= {}).merge! load_yaml(yaml_file, locale)
        end
      end

      def current_translations
        @files[FastGettext.locale] || super
      end

      # Given a yaml file return a hash of key -> translation
      def load_yaml(file, locale)
        yaml = YAML.load_file(file)
        yaml_hash_to_dot_notation(yaml.fetch(locale))
      end

      def yaml_hash_to_dot_notation(yaml_hash)
        add_yaml_key({}, nil, yaml_hash)
      end

      def add_yaml_key(result, prefix, hash)
        hash.each_pair do |key, value|
          if value.is_a?(Hash)
            add_yaml_key(result, yaml_dot_notation(prefix, key), value)
          else
            result[yaml_dot_notation(prefix, key)] = value
          end
        end
        result
      end

      def yaml_dot_notation(a, b) # rubocop:disable Naming/UncommunicativeMethodParamName
        a ? "#{a}.#{b}" : b
      end
    end
  end
end
