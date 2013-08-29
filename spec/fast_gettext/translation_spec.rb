require "spec_helper"

describe FastGettext::Translation do
  include FastGettext::Translation
  include FastGettext::TranslationMultidomain

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

    it "returns the original string if its translation is blank" do
      _('Untranslated').should == 'Untranslated'
    end

    it "does not return the blank translation if a string's translation is blank" do
      _('Untranslated').should_not == ''
    end

    it "returns key if not translation was found" do
      _('NOT|FOUND').should == 'NOT|FOUND'
    end

    it "does not return the gettext meta information" do
      _('').should == ''
    end

    it "returns nil when specified" do
      _('not found'){nil}.should be_nil
    end

    it "returns block when specified" do
      _('not found'){:block}.should == :block
    end
  end

  describe :n_ do
    before do
      FastGettext.pluralisation_rule = nil
    end

    it "translates pluralized" do
      n_('Axis','Axis',1).should == 'Achse'
      n_('Axis','Axis',2).should == 'Achsen'
      n_('Axis','Axis',0).should == 'Achsen'
    end

    describe "pluralisations rules" do
      it "supports abstract pluralisation rules" do
        FastGettext.pluralisation_rule = lambda{|n|2}
        n_('a','b','c','d',4).should == 'c'
      end

      it "supports false as singular" do
        FastGettext.pluralisation_rule = lambda{|n|n!=2}
        n_('singular','plural','c','d',2).should == 'singular'
      end

      it "supports true as plural" do
        FastGettext.pluralisation_rule = lambda{|n|n==2}
        n_('singular','plural','c','d',2).should == 'plural'
      end
    end

    it "returns a simple translation when no combined was found" do
      n_('Axis','NOTFOUNDs',1).should == 'Achse'
    end

    it "returns the appropriate key if no translation was found" do
      n_('NOTFOUND','NOTFOUNDs',1).should == 'NOTFOUND'
      n_('NOTFOUND','NOTFOUNDs',2).should == 'NOTFOUNDs'
    end

    it "returns the last key when no translation was found and keys where to short" do
      FastGettext.pluralisation_rule = lambda{|x|4}
      n_('Apple','Apples',2).should == 'Apples'
    end

    it "returns block when specified" do
      n_('not found'){:block}.should == :block
    end
  end

  describe :s_ do
    it "translates simple text" do
      s_('car').should == 'Auto'
    end

    it "returns cleaned key if a translation was not found" do
      s_("XXX|not found").should == "not found"
    end

    it "can use a custom seperator" do
      s_("XXX/not found",'/').should == "not found"
    end

    it "returns block when specified" do
      s_('not found'){:block}.should == :block
    end
  end

  describe :N_ do
    it "returns the key" do
      N_('XXXXX').should == 'XXXXX'
    end
  end

  describe :Nn_ do
    it "returns the keys as array" do
      Nn_('X','Y').should == ['X','Y']
    end
  end

  describe :ns_ do
    it "translates whith namespace" do
      ns_('Fruit|Apple','Fruit|Apples',2).should == 'Apples'
    end

    it "returns block when specified" do
      ns_('not found'){:block}.should == :block
      ns_('not found'){nil}.should be_nil
    end
  end

  describe :multi_domain do
    before do
      setup_extra_domain
    end

    describe :_in_domain do
      it "changes domain via in_domain" do
        Thread.current[:fast_gettext_text_domain].should == "test"
        _in_domain "fake" do
          Thread.current[:fast_gettext_text_domain].should == "fake"
        end
        Thread.current[:fast_gettext_text_domain].should == "test"
      end
    end

    describe :d_ do
      it "translates simple text" do
        d_('test', 'car').should == 'Auto'
      end

      it "translates simple text in different domain" do
        d_('test2', 'car').should == 'Auto 2'
      end

      it "translates simple text in different domain one transaction" do
        d_('test', 'car').should == 'Auto'
        d_('test2', 'car').should == 'Auto 2'
      end

      it "returns the original string if its translation is blank" do
        d_('test', 'Untranslated').should == 'Untranslated'
      end

      it "sets text domain back to previous one" do
        old_domain = FastGettext.text_domain
        d_('test2', 'car').should == 'Auto 2'
        FastGettext.text_domain.should == old_domain
      end

      it "returns appropriate key if translation is not found in a domain" do
        FastGettext.translation_repositories['fake'] = {}
        d_('fake', 'car').should == 'car'
      end
    end

    describe :dn_ do
      before do
        FastGettext.pluralisation_rule = nil
      end

      it "translates pluralized" do
        dn_('test', 'Axis','Axis',1).should == 'Achse'
        dn_('test2', 'Axis','Axis',1).should == 'Achse 2'
      end

      it "returns a simple translation when no combined was found" do
        dn_('test', 'Axis','NOTFOUNDs',1).should == 'Achse'
        dn_('test2', 'Axis','NOTFOUNDs',1).should == 'Achse 2'
      end

      it "returns the appropriate key if no translation was found" do
        dn_('test', 'NOTFOUND','NOTFOUNDs',1).should == 'NOTFOUND'
        dn_('test', 'NOTFOUND','NOTFOUNDs',2).should == 'NOTFOUNDs'
      end

      it "returns the last key when no translation was found and keys where to short" do
        FastGettext.pluralisation_rule = lambda{|x|4}
        dn_('test', 'Apple','Apples',2).should == 'Apples'
      end
    end

    describe :ds_ do
      it "translates simple text" do
        ds_('test2', 'car').should == 'Auto 2'
        ds_('test', 'car').should == 'Auto'
      end

      it "returns cleaned key if a translation was not found" do
        ds_('test2', "XXX|not found").should == "not found"
      end

      it "can use a custom seperator" do
        ds_('test2', "XXX/not found",'/').should == "not found"
      end
    end

    describe :dns_ do
      it "translates whith namespace" do
        dns_('test', 'Fruit|Apple','Fruit|Apples',2).should == 'Apples'
        dns_('test2', 'Fruit|Apple','Fruit|Apples',2).should == 'Apples'
      end
    end
  end

  describe :multidomain_all do
    before do
      setup_extra_domain
    end

    describe :D_ do
      it "translates simple text" do
        D_('not found').should == 'not found'
        D_('only in test2 domain').should == 'nur in test2 Domain'
      end

      it "returns translation from random domain" do
        D_('car').should match('(Auto|Auto 2)')
      end

      it "sets text domain back to previous one" do
        old_domain = FastGettext.text_domain
        D_('car').should == 'Auto'
        FastGettext.text_domain.should == old_domain
      end
    end

    describe :Dn_ do
      before do
        FastGettext.pluralisation_rule = nil
      end

      it "translates pluralized" do
        Dn_('Axis','Axis',1).should match('(Achse|Achse 2)')
      end

      it "returns a simple translation when no combined was found" do
        Dn_('Axis','NOTFOUNDs',1).should match('(Achse|Achse 2)')
      end

      it "returns the appropriate key if no translation was found" do
        Dn_('NOTFOUND','NOTFOUNDs',1).should == 'NOTFOUND'
      end

      it "returns the last key when no translation was found and keys where to short" do
        Dn_('Apple','Apples',2).should == 'Apples'
      end
    end

    describe :Ds_ do
      it "translates simple text" do
        Ds_('car').should match('(Auto|Auto 2)')
      end

      it "returns cleaned key if a translation was not found" do
        Ds_("XXX|not found").should == "not found"
      end

      it "can use a custom seperator" do
        Ds_("XXX/not found",'/').should == "not found"
      end
    end

    describe :Dns_ do
      it "translates whith namespace" do
        Dns_('Fruit|Apple','Fruit|Apples',1).should == 'Apple'
        Dns_('Fruit|Apple','Fruit|Apples',2).should == 'Apples'
      end

      it "returns cleaned key if a translation was not found" do
        Dns_("XXX|not found", "YYY|not found", 1).should == "not found"
        Dns_("XXX|not found", "YYY|not found", 2).should == "not found"
      end
    end
  end

  describe :caching do
    describe :cache_hit do
      before do
        #singular cache keys
        FastGettext.current_cache['xxx'] = '1'

        #plural cache keys
        FastGettext.current_cache['||||xxx'] = ['1','2']
        FastGettext.current_cache['||||xxx||||yyy'] = ['1','2']
      end

      it "uses the cache when translating with _" do
        _('xxx').should == '1'
      end

      it "uses the cache when translating with s_" do
        s_('xxx').should == '1'
      end

      it "uses the cache when translating with n_" do
        n_('xxx','yyy',1).should == '1'
      end

      it "uses the cache when translating with n_ and single argument" do
        n_('xxx',1).should == '1'
      end
    end

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

    it "caches different textdomains seperatly for d_" do
      _('car').should == 'Auto'

      FastGettext.translation_repositories['fake'] = {}
      d_('fake', 'car').should == 'car'
      d_('test','car').should == 'Auto'
    end
  end
end
