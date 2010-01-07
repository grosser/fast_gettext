current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

include FastGettext::Translation

module FastGettext
  module TranslationRepository
    class Dummy
      def initialize(name, options)
      end
    end
  end
end

describe FastGettext::TranslationRepository do
  describe "build" do
    it "auto requires class by default" do
      lambda { FastGettext::TranslationRepository.build('xx', { :type => 'invalid'}) }.should raise_error(LoadError)
    end

    it "can have auto-require disabled" do
      FastGettext::TranslationRepository.build('xx', { :type => 'dummy', :external => true })
    end

  end
end