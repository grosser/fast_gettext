require File.expand_path('spec/spec_helper')

describe 'Iconv' do
  it "also works when Iconv was not found locally" do
    system("bundle exec ruby spec/cases/iconv_fallback.rb").should == true
  end
end
