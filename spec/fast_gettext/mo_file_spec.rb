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
