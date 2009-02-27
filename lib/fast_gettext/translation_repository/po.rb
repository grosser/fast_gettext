require 'fast_gettext/translation_repository/base'
require 'fast_gettext/translation_repository/mo'
module FastGettext
  module TranslationRepository
     # Responsibility:
    #  - find and store po files
    #  - provide access to translations in po files
    class Po < Mo
      def initialize(name,options={})
        require File.join(File.dirname(__FILE__),'..','..','..','vendor','poparser')
        require 'fast_gettext/mo_file'
        find_files_in_locale_folders("#{name}.po",options[:path]) do |locale,file|
          mo_file = FastGettext::GetText::MOFile.new
          FastGettext::GetText::PoParser.new.parse(File.read(file),mo_file)
          @files[locale] = MoFile.new(mo_file)
        end
      end
    end
  end
end