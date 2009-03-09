current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'..','locale'))
FastGettext.text_domain = 'test'

include FastGettext::Translation

describe FastGettext::Translation do
  before do
    FastGettext.available_locales = ['en','de']
    FastGettext.locale = 'de'
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

    it "supports abstract pluralisation rules" do
      begin
        FastGettext.current_repository.pluralisation_rule = lambda{|n|2}
        n_('a','b','c','d',4).should == 'c'
      ensure
        #restore default
        FastGettext.current_repository.pluralisation_rule = lambda{|n|n==1?0:1}
      end
    end

    it "returns the appropriate msgid if no translation was found" do
      n_('NOTFOUND','NOTFOUNDs',1).should == 'NOTFOUND'
      n_('NOTFOUND','NOTFOUNDs',2).should == 'NOTFOUNDs'
    end

    it "returns the last msgid when no translation was found and msgids where to short" do
      FastGettext.current_repository.pluralisation_rule = lambda{|x|4}
      n_('Apple','Apples',2).should == 'Apples'
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