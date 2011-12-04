require File.expand_path('spec/spec_helper')
require 'fast_gettext/po_file'

de_file = File.join('spec','locale','de','test.po')
de = FastGettext::PoFile.to_mo_file(de_file)

describe FastGettext::PoFile do
  before :all do
    File.exist?(de_file).should == true
  end

  it "parses a file" do
    de['car'].should == 'Auto'
  end

  it "stores untranslated values as nil" do
    de['Car|Model'].should == "Modell"
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
end
