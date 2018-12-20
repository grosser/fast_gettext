require "spec_helper"

SingleCov.covered!

describe 'FastGettext::TranslationRepository::Yaml' do
  before do
    @rep = FastGettext::TranslationRepository.build('test', :path => File.join('spec', 'locale', 'yaml', 'valid'), :type => :yaml)
    @rep.is_a?(FastGettext::TranslationRepository::Yaml).should == true
    FastGettext.locale = 'de'
  end

  it "can be built" do
    @rep.available_locales.sort.should == ['de', 'en', 'zh_CN']
  end

  it "accumulates segmented locales" do
    FastGettext.locale = 'en'
    locales = @rep.send(:current_translations)
    locales['simple'].should == 'easy'
    locales['additional'].should == 'validate'
  end

  it "translates nothing when locale is unsupported" do
    FastGettext.locale = 'xx'
    @rep['simple'].should == nil
  end

  it "does not translated categories" do
    @rep['cars'].should == nil
  end

  it "can translate simple" do
    @rep['simple'].should == 'einfach'
  end

  it "can translate nested" do
    @rep['cars.car'].should == 'Auto'
  end

  it "can pluralize" do
    @rep.plural('cars.axis').should == ['Achse', 'Achsen', nil, nil]
  end

  describe :reload do
    before do
      yaml = YAML.load_file('spec/locale/yaml/invalid/de2.yml')

      YAML.stub(:load_file).and_return('en' => {}, 'de' => {}, 'zh_CN' => {})
      YAML.stub(:load_file).with('spec/locale/yaml/valid/de.yml').and_return(yaml)
    end

    it "can reload" do
      FastGettext.locale = 'de'

      @rep['cars.car'].should == 'Auto'

      @rep.reload

      @rep['cars.car'].should == 'Aufzugskabine'
    end

    it "returns true" do
      @rep.reload.should == true
    end
  end

  it "handles unfound plurals with nil" do
    @rep.plural('cars.xxx').should == [nil, nil, nil, nil]
  end

  it "can be used to translate plural forms" do
    FastGettext.stub(:current_repository).and_return @rep
    FastGettext.n_('cars.axis','cars.axis',2).should == 'Achsen'
    FastGettext.n_('cars.axis',2).should == 'Achsen'
    FastGettext.n_('cars.axis',1).should == 'Achse'
  end

  4.times do |i|
    it "can be used to do wanky pluralisation rules #{i}" do
      FastGettext.stub(:current_repository).and_return @rep
      @rep.stub(:pluralisation_rule).and_return lambda{|x| i}
      FastGettext.n_('cars.silly',1).should == i.to_s # cars.silly translations are 0,1,2,3
    end
  end

  it "can use custom pluraliztion rules" do
    FastGettext.locale = 'en'
    {0 => 0, 1 => 1, 2 => 2, 3 => 0}.each do |input, expected|
      @rep.pluralisation_rule.call(input).should == expected
    end
  end

  context 'invalid yaml file' do
    let(:invalid_yamls) do
      -> { FastGettext::TranslationRepository.build('test', :path => File.join('spec', 'locale', 'yaml', 'invalid'), :type => :yaml) }
    end

    specify { invalid_yamls.should raise_error(KeyError) }
  end

  context 'yaml file is a country specific variant of a language' do
    before { FastGettext.locale = 'zh_CN' }

    it "can translate simple" do
      @rep['simple'].should == '简单'
    end

    it "can translate nested" do
      @rep['cars.car'].should == '汽车'
    end

    it "can pluralize" do
      @rep.plural('cars.axis').should == ['轴', '轴', nil, nil]
    end
  end
end
