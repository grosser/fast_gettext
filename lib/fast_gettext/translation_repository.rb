# frozen_string_literal: true

module FastGettext
  # Responsibility:
  #  - decide which repository to choose from given input
  module TranslationRepository
    def self.build(name, options)
      type = options[:type] || :mo
      class_name = type.to_s.split('_').map(&:capitalize).join
      unless FastGettext::TranslationRepository.constants.map(&:to_s).include?(class_name)
        require "fast_gettext/translation_repository/#{type}"
      end
      const_get(class_name).new(name, options)
    end
  end
end
