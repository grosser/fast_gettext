require File.join(File.dirname(__FILE__),'spec_helper')

describe 'unconfigured' do
  it "gives a useful error message when trying to just translate" do
    FastGettext.text_domain = nil
    x=1
    begin
      FastGettext._('x')
    rescue
      x=$!
    end
    x.to_s.should =~ /NoTextDomainConfigured/
  end
  it "gives a useful error message when only locale was set" do
    FastGettext.locale = 'de'
    x=1
    begin
      FastGettext._('x')
    rescue
      x=$!
    end
    x.to_s.should =~ /NoTextDomainConfigured/
  end
end