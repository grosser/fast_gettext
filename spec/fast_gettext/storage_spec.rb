current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

include FastGettext::Storage

describe Storage do
  def thread_save(method)
    send("#{method}=",1)

    # mess around with other threads
    threads = []
    100.times do |i|
      threads << Thread.new {send("#{method}=",i)}
    end
    threads.each(&:join)
    
    send(method) == 1
  end

  [:locale, :available_locales, :text_domain].each do |method|
    it "stores #{method} thread-save" do
      thread_save(:locale).should == true
    end
  end

  it "does not store text_domains thread-save" do
    thread_save(:text_domains).should == false
  end
end