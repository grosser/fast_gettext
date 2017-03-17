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

    it "exposes name and options for reading" do
      options = { :type => 'base' }
      repo = FastGettext::TranslationRepository.build('xx', options)
      repo.should respond_to(:name)
      repo.should_not respond_to(:name=)
      repo.should respond_to(:options)
      repo.should_not respond_to(:options=)
    end
  end
end
