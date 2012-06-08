require "spec_helper"

describe 'FastGettext::TranslationRepository::Po' do
  before do
    @rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec','locale'),:type=>:po)
    @rep.is_a?(FastGettext::TranslationRepository::Po).should be_true
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
    it "should warn on fuzzy and not use it by default" do
      FastGettext.locale = 'de'
      $stderr.should_receive(:print).at_least(:once)
      rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec','fuzzy_locale'),:type=>:po)
      rep['%{relative_time} ago'].should be_nil
    end

    it "should ignore fuzzy and not use it when set ignore_fuzzy to true" do
      FastGettext.locale = 'de'
      $stderr.should_not_receive(:print)
      rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec','fuzzy_locale'),:type=>:po, :ignore_fuzzy => true)
      rep['%{relative_time} ago'].should be_nil
    end

    it "should warn on fuzzy and use fuzzy when set use_fuzzy to true" do
      FastGettext.locale = 'de'
      $stderr.should_receive(:print).at_least(:once)
      rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec','fuzzy_locale'),:type=>:po, :use_fuzzy => true)
      rep['%{relative_time} ago'].should == 'vor %{relative_time}'
    end

    it "should ignore fuzzy and use fuzzy when set ignore_fuzzy and use_fuzzy to true" do
      FastGettext.locale = 'de'
      $stderr.should_not_receive(:print)
      rep = FastGettext::TranslationRepository.build('test',:path=>File.join('spec','fuzzy_locale'),:type=>:po, :use_fuzzy => true, :ignore_fuzzy => true)
      rep['%{relative_time} ago'].should == 'vor %{relative_time}'
    end
  end

  describe 'obsolete' do
    it "should warn on obsolete by default" do
      $stderr.should_receive(:print).at_least(:once)
      FastGettext::TranslationRepository.build('test',:path=>File.join('spec','obsolete_locale'),:type=>:po)
    end

    it "should ignore obsolete when told to do so" do
      $stderr.should_not_receive(:print)
      FastGettext::TranslationRepository.build('test',:path=>File.join('spec','obsolete_locale'),:type=>:po, :ignore_obsolete => true)
    end
  end
end
