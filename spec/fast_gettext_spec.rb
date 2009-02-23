require File.expand_path("spec_helper", File.dirname(__FILE__))

FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'locale'))
FastGettext.text_domain = 'test'
FastGettext.available_locales = ['en','de']
FastGettext.locale = 'de'

include FastGettext

describe FastGettext do
  it "provides access to FastGettext::Translations methods" do
    FastGettext._('car').should == 'Auto'
    _('car').should == 'Auto'
    s_("XXX|not found").should == "not found"
    n_('Axis','Axis',1).should == 'Achse'
    N_('XXXXX').should == 'XXXXX'
    Nn_('X','Y').should == ['X','Y']
  end
  it "is extended to a class and included into a class" do
    class IncludeTest
      include FastGettext::Translation
      def self.ext
        _('car')
      end
      def inc
        _('car')
      end
    end
    IncludeTest.ext.should == 'Auto'
    IncludeTest.new.inc.should == 'Auto'
  end
end