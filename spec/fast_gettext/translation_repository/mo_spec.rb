require "spec_helper"

describe 'FastGettext::TranslationRepository::Mo' do
  before do
    @rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec', 'locale'))
    @rep.is_a?(FastGettext::TranslationRepository::Mo).should be_true
  end

  it "can be built" do
    @rep.available_locales.sort.should == ['de','en','gsw_CH']
  end

  it "can translate" do
    FastGettext.locale = 'de'
    @rep['car'].should == 'Auto'
  end

  it "can pluralize" do
    FastGettext.locale = 'de'
    @rep.plural('Axis','Axis').should == ['Achse','Achsen']
  end

  describe :reload do
    before do
      mo_file = FastGettext::MoFile.new('spec/locale/de/LC_MESSAGES/test2.mo')

      FastGettext::MoFile.stub(:new).and_return(FastGettext::MoFile.empty)
      FastGettext::MoFile.stub(:new).with('spec/locale/de/LC_MESSAGES/test.mo').and_return(mo_file)
    end

    it "can reload" do
      FastGettext.locale = 'de'

      @rep['Untranslated'].should be_nil

      @rep.reload

      @rep['Untranslated'].should == 'Translated'
    end

    it "returns true" do
      @rep.reload.should be_true
    end
  end

  it "has access to the mo repositories pluralisation rule" do
    FastGettext.locale = 'en'
    rep = FastGettext::TranslationRepository.build('plural_test',:path=>File.join('spec','locale'))
    rep['car'].should == 'Test'#just check it is loaded correctly
    rep.pluralisation_rule.call(2).should == 3
  end

  it "can work in SAFE mode" do
    `ruby spec/cases/safe_mode_can_handle_locales.rb 2>&1`.should == 'true'
  end
end
