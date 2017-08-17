module FastGettext
  # Responsibility:
  #  - decide which repository to choose from given input
  module TranslationRepository
    VALID_TYPES = %i[base chain db logger merge mo po yaml].freeze

    extend self

    def build(name, options)
      type = options[:type] ? options[:type].to_sym : :mo

      raise ArgumentError, "Invalid translation repository type" unless VALID_TYPES.include?(type)

      class_name = type.to_s.split('_').map(&:capitalize).join
      unless FastGettext::TranslationRepository.constants.map{|c|c.to_s}.include?(class_name)
        require "#{__dir__}/translation_repository/#{type}.rb".untaint
      end
      eval(class_name).new(name,options)
    end
  end
end
