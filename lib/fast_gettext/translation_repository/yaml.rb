require 'fast_gettext/translation_repository/base'
require 'find'
module FastGettext
  module TranslationRepository
    # Responsibility:
    #  - find and store yaml files
    #  - provide access to translations in yaml files
    class Yaml < Base
      def initialize(name,options={})
        find_and_store_files(name, options)
        super
      end

      def available_locales
        @files.keys
      end

      def pluralisation_rule
        current_translations.pluralisation_rule
      end

      protected

      MAX_FIND_DEPTH = 10

      def find_and_store_files(name, options)
        # parse all .yml files with the right name, that sit in config/locales folder
        @files = {}
        find_files(options[:path], /\.yml$/).each do |yaml_file|
          if yaml_file =~ /([a-z][a-z])\.yml$/
            locale = $1
            @files[locale] = load_yaml(yaml_file, locale)
          end
        end
      end

      def current_translations
        @files[FastGettext.locale] || MoFile.empty
      end

      # Given a yaml file return a hash of key -> translation
      def load_yaml(file, locale = nil)
        yaml = YAML.load_file(file)
        locale ||= yaml.keys.first
        yaml_hash_to_dot_notation(yaml[locale])
      end

      def find_files(base_dir, matching = /\.yml$/)
        files = []
        Find.find(base_dir) do |path|
          if FileTest.directory?(path)
            if File.basename(path)[0] == ?.
              Find.prune       # Don't look any further into this directory.
            else
              next
            end
          elsif path =~ matching
            files << path
          end
        end
        files
      end

      def yaml_hash_to_dot_notation(yaml_hash)
        add_yaml_key({}, "", yaml_hash)
      end

      def add_yaml_key(result, path, sub_hash)
        sub_hash.each_pair do |key, value|
          if value.kind_of?(Hash)
            add_yaml_key(result, yaml_not_notation(path + "." + key), value)
          else
            result[yaml_not_notation(path + "." + key)] = value
          end
        end
        result
      end

      def yaml_not_notation(key)
        key.sub(/^\./, '')
      end

    end
  end
end