require File.expand_path("spec_helper", File.dirname(__FILE__))

FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'locale'))
FastGettext.text_domain = 'test'
FastGettext.available_locales = ['en','de']
FastGettext.locale = 'de'

include FastGettext

describe FastGettext do
  it "provides access to FastGettext::Translations methods" do
    _('car').should == 'Auto'
    s_("XXX|not found").should == "not found"
    n_('Axis','Axis',1).should == 'Achse'
    N_('XXXXX').should == 'XXXXX'
    Nn_('X','Y').should == ['X','Y']
  end
end