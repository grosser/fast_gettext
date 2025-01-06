require "spec_helper"
require 'fast_gettext/translation_repository/base'

SingleCov.covered! uncovered: 10

describe 'FastGettext::TranslationRepository::Base' do
  before do
    @rep = FastGettext::TranslationRepository::Base.new('x')
  end

  it "can be built" do
    @rep.available_locales.should == []
  end

  it "cannot translate" do
    @rep['car'].should == nil
  end

  it "cannot pluralize" do
    @rep.plural('Axis','Axis').should == []
  end

  it "can be reloaded" do
    @rep.reload.should == true
  end
end
