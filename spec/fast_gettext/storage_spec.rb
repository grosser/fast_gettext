current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

include FastGettext::Storage

describe Storage do
  def thread_save(method)
    send("#{method}=",'de')

    # mess around with other threads
    100.times do |i|
      Thread.new {FastGettext.send("#{method}=",'en')}
    end
    
    send(method) == 'de'
  end

  [:locale, :available_locales, :text_domain, :current_translations].each do |method|
    it "stores #{method} thread-save" do
      thread_save(method).should == true
    end
  end

  it "stores text_domains non-thread-safe" do
    self.text_domains[:x]=1
    t = Thread.new{self.text_domains[:x]=2}
    t.join
    self.text_domains[:x].should == 2
  end

  describe :locale do
    it "stores everything as long as available_locales is not set" do
      self.available_locales = nil
      self.locale = 'XXX'
      locale.should == 'XXX'
    end
    it "is en if no locale and no available_locale were set" do
      Thread.current['FastGettext.locale']=nil
      self.available_locales = nil
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
  end

  describe :silence_errors do
    before do
      FastGettext.text_domain = 'xxx'
    end
    it "raises when a textdomain was empty" do
      begin 
        FastGettext._('x')
        x=2
      rescue
        x=1
      end
      x.should == 1
    end
    
    it "can silence erros" do
      FastGettext.silence_errors
      FastGettext._('x').should == 'x'
    end
  end
end