current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','spec_helper')

#just to make sure we did not mess up while copying...
describe String do
  it "substitudes using % + Hash" do
    "x%{name}y" %{:name=>'a'}.should == 'xay'
  end
  it "substitudes using % + Array" do
    ("x%sy%s" % ['a','b']).should == 'xayb'
  end
end