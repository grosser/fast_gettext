current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

include FastGettext::Translation

describe FastGettext::Translation do
  before do
    default_setup
  end

  describe "unknown locale" do
    before do
      FastGettext.available_locales = nil
      FastGettext.locale = 'xx'
    end

    it "does not translate" do
      _('car').should == 'car'
    end

    it "does not translate plurals" do
      n_('car','cars',2).should == 'cars'
    end
  end

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
      n_('Axis','Axis',0).should == 'Achsen'
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

  describe :caching do
    it "caches different locales seperatly" do
      FastGettext.locale = 'en'
      _('car').should == 'car'
      FastGettext.locale = 'de'
      _('car').should == 'Auto'
    end

    it "caches different textdomains seperatly" do
      _('car').should == 'Auto'

      FastGettext.translation_repositories['fake'] = {}
      FastGettext.text_domain = 'fake'
      _('car').should == 'car'

      FastGettext.text_domain = 'test'
      _('car').should == 'Auto'
    end
  end
end