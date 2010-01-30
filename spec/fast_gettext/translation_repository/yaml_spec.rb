current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','..','spec_helper')


describe 'FastGettext::TranslationRepository::Yaml' do
  before do
    @rep = FastGettext::TranslationRepository.build('test',:path=> File.join(current_folder,'..','..','locale'), :type => :yaml)
    @rep.is_a?(FastGettext::TranslationRepository::Yaml).should be_true
  end

  it "can be built" do
    @rep.available_locales.should == ['de', 'en']
  end

  it "can translate" do
    FastGettext.locale = 'de'
    @rep['cars.car'].should == 'Auto'
  end

  it "can pluralize" do
    FastGettext.locale = 'de'
    @rep.plural('cars.axis','cars.axis').should == ['Achse','Achsen']
  end

end