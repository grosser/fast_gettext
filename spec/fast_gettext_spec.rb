require "spec_helper"

default_setup
class IncludeTest
  include FastGettext::Translation
  @@xx = _('car')
  def self.ext
    _('car')
  end
  def inc
    _('car')
  end
  def self.xx
    @@xx
  end
end

describe FastGettext do
  include FastGettext
  before :all do
    default_setup
  end

  it "provides access to FastGettext::Translations methods" do
    FastGettext._('car').should == 'Auto'
    _('car').should == 'Auto'
    _("%{relative_time} ago").should == "vor %{relative_time}"
    (_("%{relative_time} ago") % {:relative_time => 1}).should == "vor 1"
    (N_("%{relative_time} ago") % {:relative_time => 1}).should == "1 ago"
    s_("XXX|not found").should == "not found"
    n_('Axis','Axis',1).should == 'Achse'
    N_('XXXXX').should == 'XXXXX'
    Nn_('X','Y').should == ['X','Y']
  end
  
  it "is extended to a class and included into a class" do
    IncludeTest.ext.should == 'Auto'
    IncludeTest.ext.should == 'Auto'
    IncludeTest.new.inc.should == 'Auto'
    IncludeTest.xx.should == 'Auto'
  end

  it "loads 3-letter locales as well" do
    FastGettext.locale = 'gsw_CH'
    FastGettext._('Car was successfully created.').should == "Z auto isch erfolgriich gspeicharat worda."
  end

  it "has a VERSION" do
    FastGettext::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end
end
