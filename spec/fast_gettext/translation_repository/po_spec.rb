require "spec_helper"

describe 'FastGettext::TranslationRepository::Po' do
  before do
    @rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec','locale'),:type=>:po)
    @rep.is_a?(FastGettext::TranslationRepository::Po).should == true
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

  it "has access to the mo repositories pluralisation rule" do
    FastGettext.locale = 'en'
    rep = FastGettext::TranslationRepository.build('plural_test',:path=>File.join('spec','locale'),:type=>:po)
    rep['car'].should == 'Test'#just check it is loaded correctly
    rep.pluralisation_rule.call(2).should == 3
  end

  describe 'fuzzy' do
    before do
      @fuzzy = File.join('spec','fuzzy_locale')
    end

    it "should use fuzzy by default" do
      $stderr.should_receive(:print).at_least(:once)
      repo = FastGettext::TranslationRepository.build('test',:path=>@fuzzy,:type=>:po)
      repo["%{relative_time} ago"].should == "vor %{relative_time}"
    end

    it "should warn on fuzzy when ignoring" do
      $stderr.should_receive(:print).at_least(:once)
      repo = FastGettext::TranslationRepository.build('test',:path=>@fuzzy,:type=>:po, :ignore_fuzzy => true)
      repo["%{relative_time} ago"].should == nil
    end

    it "should ignore fuzzy and not report when told to do so" do
      $stderr.should_not_receive(:print)
      repo = FastGettext::TranslationRepository.build('test',:path=>@fuzzy,:type=>:po, :ignore_fuzzy => true, :report_warning => false)
      repo["%{relative_time} ago"].should == nil
    end
  end

  describe 'obsolete' do
    it "should warn on obsolete by default" do
      $stderr.should_receive(:print).at_least(:once)
      FastGettext::TranslationRepository.build('test',:path=>File.join('spec','obsolete_locale'),:type=>:po)
    end

    it "should ignore obsolete when told to do so" do
      $stderr.should_not_receive(:print)
      FastGettext::TranslationRepository.build('test',:path=>File.join('spec','obsolete_locale'),:type=>:po, :report_warning => false)
    end
  end
end
