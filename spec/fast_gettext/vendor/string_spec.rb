require "spec_helper"

describe String do
  before :all do
    if "i18n gem overwrites % method".respond_to?(:interpolate_without_ruby_19_syntax)
      class String
        def %(*args)
          interpolate_without_ruby_19_syntax(*args)
        end
      end
    end
  end

  it "does not translate twice" do
    ("%{a} %{b}" % {:a=>'%{b}',:b=>'c'}).should == '%{b} c'
  end

  describe "old % style replacement" do
    it "substitudes using % + Hash" do
      ("x%{name}y" % {:name=>'a'}).should == 'xay'
    end

    it "does not substitute after %%" do
      ("%%{num} oops" % {:num => 1}).should == '%{num} oops'
    end

    it "does not substitute when nothing could be found" do
      ("abc" % {:x=>1}).should == 'abc'
    end
  end

  describe 'old sprintf style' do
    it "substitudes using % + Array" do
      ("x%sy%s" % ['a','b']).should == 'xayb'
    end
  end

  describe 'ruby 1.9 style %< replacement' do
    it "does not substitute after %%" do
      ("%%<num> oops" % {:num => 1}).should == '%<num> oops'
    end

    it "subsitutes %<something>d" do
      ("x%<hello>dy" % {:hello=>1}).should == 'x1y'
    end

    it "substitutes #b" do
      ("%<num>#b" % {:num => 1}).should == "0b1"
    end
  end

  it "raise when key was not found" do
    lambda { ("%{typo} xxx" % {:something=>1}) }.should raise_error(KeyError)
  end

  it "does not raise when key was not found if allow_invalid_keys! is enabled" do
    FastGettext.allow_invalid_keys!
    ("%{typo} xxx" % {:something=>1}).should == "%{typo} xxx"

    # cleanup
    eval(<<CODE)
class ::String
  alias :% :_fast_gettext_old_format_m
end
CODE
  end
end
