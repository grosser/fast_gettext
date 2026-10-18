# encoding: utf-8
require "spec_helper"

de_file = File.join('spec','locale','de','LC_MESSAGES','test.mo')

describe FastGettext::MoFile do
  let(:de) { FastGettext::MoFile.new(de_file) }

  before :all do
    File.exist?(de_file).should == true
  end

  it "parses a file" do
    de['car'].should == 'Auto'
  end

  it "stores untranslated values as nil" do
    de['Untranslated'].should == nil
  end

  it "finds pluralized values" do
    de.plural('Axis','Axis').should == ['Achse','Achsen']
  end

  it "returns empty array when pluralisation could not be found" do
    de.plural('Axis','Axis','Axis').should == []
  end

  it "can access plurals through []" do
    de['Axis'].should == 'Achse' #singular
  end

  it "can successfully translate non-ASCII keys" do
    de["Umläüte"].should == "Umlaute"
  end

  it "doesn't load the file when new instance is created" do
    FastGettext::GetText::MOFile.should_not_receive(:open)
    FastGettext::MoFile.new(de_file)
  end

  it "loads the file when a translation is touched for the first time" do
    FastGettext::GetText::MOFile.should_receive(:open).once.with(de_file, "UTF-8").and_call_original

    de['car']
    de['car']
  end

  describe "eager loading" do
    let(:de) { FastGettext::MoFile.new(de_file, :eager_load => true) }

    it "loads the file when new instance is created" do
      FastGettext::GetText::MOFile.should_receive(:open).once.with(de_file, "UTF-8").and_call_original
      FastGettext::MoFile.new(de_file, :eager_load => true)
    end

    it "doesn't load the file when a translation is touched" do
      de
      FastGettext::GetText::MOFile.should_not_receive(:open)

      de['car']
      de['car']
    end

  end

  describe "#pluralisation_rule" do
    # Plural-Forms of the languages in the gettext manual
    RULES = [
      "n != 1", "n>1", "0", "n==1 ? 0 : 1",
      "n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2", # ru, uk
      "n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2", # pl
      "(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2", # cs, sk
      "n%100==1 ? 0 : n%100==2 ? 1 : n%100==3 || n%100==4 ? 2 : 3", # sl
      "n==1 ? 0 : n==2 ? 1 : n<7 ? 2 : n<11 ? 3 : 4", # ga
      "n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5", # ar
    ].freeze

    def mo_file(header)
      data = FastGettext::GetText::MOFile.new
      data[''] = header
      FastGettext::MoFile.new(data)
    end

    # How the rule was evaluated before it was compiled once.
    def reference(expression)
      ->(n) { eval(expression) } # rubocop:disable Security/Eval
    end

    it "gives the same plural index as evaluating the Plural-Forms expression" do
      RULES.each do |expression|
        rule = mo_file("Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=6; plural=#{expression};\n").pluralisation_rule
        (0..300).each { |n| rule.call(n).should == reference(expression).call(n) }
      end
    end

    it "is compiled once per file" do
      mo = mo_file("Plural-Forms: nplurals=2; plural=n != 1;\n")
      mo.pluralisation_rule.should equal(mo.pluralisation_rule)
    end

    it "is nil without Plural-Forms, also on later calls" do
      mo = mo_file("Content-Type: text/plain; charset=UTF-8\n")
      2.times { mo.pluralisation_rule.should == nil }
      FastGettext::MoFile.empty.pluralisation_rule.should == nil
    end

    it "only fails when the rule is used, if it does not compile" do
      mo = mo_file("Plural-Forms: nplurals=2; plural=n ? : 1;\n")
      mo[''].should include("Plural-Forms")
      -> { mo.pluralisation_rule.call(1) }.should raise_error(SyntaxError)
    end
  end

  describe ".empty" do
    let(:path) do
      File.expand_path("../../lib/fast_gettext/vendor/empty.mo", __dir__)
    end

    before do
      # clear the ivar cache
      described_class.remove_instance_variable(:@empty) if described_class.instance_variable_defined?(:@empty)
    end

    it "is frozen" do
      described_class.empty.should be_frozen
    end

    it "has no translations" do
      described_class.empty["foo"].should be_nil
      described_class.empty["bar"].should be_nil
    end

    it "is cached" do
      described_class.empty.object_id.should eq(described_class.empty.object_id)
    end

    it "loads empty mo file eagerly only once" do
      FastGettext::GetText::MOFile.should_receive(:open).once.with(path, "UTF-8").and_call_original

      described_class.empty
      described_class.empty
      described_class.empty["foo"]
      described_class.empty["bar"]
    end
  end
end
