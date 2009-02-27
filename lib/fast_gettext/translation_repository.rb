module FastGettext
  # Responsibility:
  #  - decide which repository to choose from given input
  module TranslationRepository
    extend self

    # only single-word types supported atm (mytype works, MyType will not)
    def build(name,options)
      type = options[:type] || :mo
      require "fast_gettext/translation_repository/#{type}"
      klas = eval(type.to_s.capitalize)
      klas.new(name,options)
    end
  end
end