require "spec_helper"

describe FastGettext::TranslationRepository do
  describe "build" do
    it "auto requires class by default" do
      lambda { FastGettext::TranslationRepository.build('xx', { :type => 'invalid'}) }.should raise_error(LoadError)
    end

    it "can have auto-require disabled" do
      FastGettext::TranslationRepository.build('xx', { :type => 'base' })
    end

    it "makes a new repository" do
      options = { :type => 'base', :external => true }
      repo = FastGettext::TranslationRepository.build('xx', options)
      repo.class.should == FastGettext::TranslationRepository::Base
      repo.name.should == 'xx'
      repo.options.should == options
    end
  end
end
