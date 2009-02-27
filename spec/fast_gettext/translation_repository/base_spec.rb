current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','..','spec_helper')
require 'fast_gettext/translation_repository/base'

describe 'FastGettext::TranslationRepository::Base' do
  before do
    @rep = FastGettext::TranslationRepository::Base.new('x')
  end
  it "can be built" do
    @rep.available_locales.should == []
  end
  it "cannot translate" do
    @rep.locale = 'de'
    @rep['car'].should == nil
  end
  it "cannot pluralize" do
    @rep.locale = 'de'
    @rep.plural('Axis','Axis',2).should == nil
  end
end