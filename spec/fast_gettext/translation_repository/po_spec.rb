current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','..','spec_helper')


describe 'FastGettext::TranslationRepository::Po' do
  before do
    @rep = FastGettext::TranslationRepository.build('test',:path=>File.join(current_folder,'..','..','locale'),:type=>:po)
    @rep.is_a? FastGettext::TranslationRepository::Po
  end
  it "can be built" do
    @rep.available_locales.should == ['de','en']
  end
  it "can translate" do
    FastGettext.locale = 'de'
    @rep['car'].should == 'Auto'
  end
  it "can pluralize" do
    FastGettext.locale = 'de'
    @rep.plural('Axis','Axis',2).should == 'Achsen'
  end
end