require 'fast_gettext/translation_repository/base'

module FastGettext
  module TranslationRepository
    # Responsibility:
    #  - delegate calls to members of the chain in turn
    class Chain < Base
      attr_accessor :chain

      def initialize(name,options={})
        super
        self.chain = options[:chain]
      end

      def available_locales
        chain.map{|c|c.available_locales}.flatten.uniq
      end

      def [](key)
        chain.each do |c|
          result = c[key] and return result
        end
        nil
      end

      def plural(*msgids)
        chain.each do |c|
          result = c.plural(*msgids)
          return result unless result.compact.empty?
        end
        []
      end
    end
  end
end