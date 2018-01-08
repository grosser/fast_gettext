require "spec_helper"
require 'fast_gettext/po_file'

de_file = File.join('spec','locale','de','test.po')

describe FastGettext::PoFile do
  let(:open_args) {
    if RUBY_VERSION < "1.9"
      [ de_file]
    else
      [ de_file, "r:UTF-8" ]
    end
  }

  let(:de) { FastGettext::PoFile.new(de_file) }

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

  it "unescapes '\\'" do
    de["You should escape '\\' as '\\\\'."].should == "Du solltest '\\' als '\\\\' escapen."
  end

  it "doesn't load the file when new instance is created" do
    File.should_not_receive(:open).with(*open_args)
    FastGettext::PoFile.new(de_file)
  end

  it "loads the file when a translation is touched for the first time" do
    File.should_receive(:open).once.with(*open_args).and_call_original

    de['car']
    de['car']
  end

  describe "eager loading" do
    let(:de) { FastGettext::PoFile.new(de_file, :eager_load => true) }

    it "loads the file when new instance is created" do
      File.should_receive(:open).once.with(*open_args).and_call_original
      FastGettext::PoFile.new(de_file, :eager_load => true)
    end

    it "doesn't load the file when a translation is touched" do
      de
      File.should_not_receive(:open).with(*open_args)

      de['car']
      de['car']
    end

  end
end
