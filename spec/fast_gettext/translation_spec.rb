current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'..','locale'))
FastGettext.text_domain = 'test'
FastGettext.available_locales = ['en','de']
FastGettext.locale = 'de'

include FastGettext::Translation

describe FastGettext::Translation do
  describe :_ do
    it "translates simple text" do
      _('car').should == 'Auto'
    end
    it "returns msgid if not translation was found" do
      _('NOT|FOUND').should == 'NOT|FOUND'
    end
  end

  describe :n_ do
    it "translates pluralized" do
      n_('Axis','Axis',1).should == 'Achse'
      n_('Axis','Axis',2).should == 'Achsen'
      n_('Axis','Axis',0).should == 'Achse'
    end
    it "returns the appropriate msgid if no translation was found" do
      n_('NOTFOUND','NOTFOUNDs',1).should == 'NOTFOUND'
      n_('NOTFOUND','NOTFOUNDs',2).should == 'NOTFOUNDs'
    end
  end

  describe :s_ do
    it "translates simple text" do
      _('car').should == 'Auto'
    end
    it "returns cleaned msgid if a translation was not found" do
      s_("XXX|not found").should == "not found"
    end
    it "can use a custom seperator" do
      s_("XXX/not found",'/').should == "not found"
    end
  end

  describe :N_ do
    it "returns the msgid" do
      N_('XXXXX').should == 'XXXXX'
    end
  end

  describe :Nn_ do
    it "returns the msgids as array" do
      Nn_('X','Y').should == ['X','Y']
    end
  end
end