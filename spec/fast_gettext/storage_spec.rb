current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

include FastGettext::Storage

describe 'Storage' do
  before do
    self.default_text_domain = nil
  end

  def thread_save(method)
    send("#{method}=",'de')

    # mess around with other threads
    100.times do
      Thread.new {FastGettext.send("#{method}=",'en')}
    end
    
    send(method) == 'de'
  end

  [:locale, :available_locales, :text_domain].each do |method|
    it "stores #{method} thread-save" do
      thread_save(method).should == true
    end
  end

  it "stores translation_repositories non-thread-safe" do
    self.translation_repositories[:x]=1
    t = Thread.new{self.translation_repositories[:x]=2}
    t.join
    self.translation_repositories[:x].should == 2
  end

  describe :default_text_domain do
    it "stores default_text_domain non-thread-safe" do
      self.default_text_domain=1
      t = Thread.new{self.default_text_domain=2}
      t.join
      self.default_text_domain.should == 2
    end

    it "uses default_text_domain when text_domain is not set" do
      self.text_domain = nil
      self.default_text_domain = 'x'
      text_domain.should == 'x'
    end

    it "does not use default when domain is set" do
      self.text_domain = 'x'
      self.default_text_domain = 'y'
      text_domain.should == 'x'
    end
  end

  describe :locale do
    it "stores everything as long as available_locales is not set" do
      self.available_locales = nil
      self.locale = 'XXX'
      locale.should == 'XXX'
    end

    it "is en if no locale and no available_locale were set" do
      FastGettext.send(:_locale=,nil)
      self.available_locales = nil
      locale.should == 'en'
    end

    it "does not change the locale if locales was called with nil" do
      self.locale = nil
      locale.should == 'en'
    end

    it "is the first available_locale if one was set" do
      self.available_locales = ['de']
      locale.should == 'de'
    end

    it "does not store a locale if it is not available" do
      self.available_locales = ['de']
      self.locale = 'en'
      locale.should == 'de'
    end

    it "set_locale returns the old locale if the new could not be set" do
      self.locale = 'de'
      self.available_locales = ['de']
      self.set_locale('en').should == 'de'
    end

    {
      'Opera' => "de-DE,de;q=0.9,en;q=0.8",
      'Firefox' => "de-de,de;q=0.8,en-us;q=0.5,en;q=0.3",
    }.each do |browser,accept_language|
      it "sets the locale from #{browser} headers" do
        FastGettext.available_locales = ['de_DE','de','xx']
        FastGettext.locale = 'xx'
        FastGettext.locale = accept_language
        FastGettext.locale.should == 'de_DE'
      end
    end

    it "sets a unimportant locale if it is the only available" do
      FastGettext.available_locales = ['en','xx']
      FastGettext.locale = "de-de,de;q=0.8,en-us;q=0.5,en;q=0.3"
      FastGettext.locale.should == 'en'
    end

    it "sets locale from comma seperated" do
      FastGettext.available_locales = ['de_DE','en','xx']
      FastGettext.locale = "de,de-de,en"
      FastGettext.locale.should == 'de_DE'
    end
  end

  describe :silence_errors do
    before do
      FastGettext.text_domain = 'xxx'
    end

    it "raises when a textdomain was empty" do
      begin 
        FastGettext._('x')
        "".should == "success!?"
      rescue FastGettext::Storage::NoTextDomainConfigured
      end
    end

    it "can silence erros" do
      FastGettext.silence_errors
      FastGettext._('x').should == 'x'
    end
  end

  describe :current_cache do
    before do
      FastGettext.text_domain = 'xxx'
      FastGettext.available_locales = ['de','en']
      FastGettext.locale = 'de'
      FastGettext._('abc')
      FastGettext.locale = 'en'
    end

    it "stores a translation seperate by locale" do
      FastGettext.current_cache['abc'].should == nil
    end

    it "stores a translation seperate by domain" do
      FastGettext.locale = 'de'
      FastGettext.text_domain = nil
      FastGettext.current_cache['abc'].should == nil
    end

    it "cache is restored through setting of default_text_domain" do
      FastGettext.locale = 'de'
      FastGettext.text_domain = nil
      FastGettext.default_text_domain = 'xxx'
      FastGettext.current_cache['abc'].should == 'abc'
    end

    it "stores a translation permanently" do
      FastGettext.locale = 'de'
      FastGettext.current_cache['abc'].should == 'abc'
    end
  end

  describe NoTextDomainConfigured do
    it "shows what to do" do
      NoTextDomainConfigured.new.to_s.should =~ /FastGettext\.add_text_domain/
    end

    it "warns when text_domain is nil" do
      FastGettext.text_domain = nil
      NoTextDomainConfigured.new.to_s.should =~ /\(nil\)/
    end

    it "shows current text_domain" do
      FastGettext.text_domain = 'xxx'
      NoTextDomainConfigured.new('xxx').to_s.should =~ /xxx/
    end
  end
end