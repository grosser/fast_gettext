current_folder = File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path("../../lib", current_folder)

describe 'Iconv' do
  it "also works when Iconv was not found locally" do
    #prepare load path
    $LOAD_PATH.unshift File.join(current_folder,'fake_load_path')
    test = 1
    begin
      require 'iconv'
    rescue LoadError
      test = 2
    end
    test.should == 2

    #load fast_gettext
    require 'fast_gettext'

    FastGettext.add_text_domain('test',:path=>File.join(File.dirname(__FILE__),'..','locale'))
    FastGettext.text_domain = 'test'
    FastGettext.available_locales = ['en','de']
    FastGettext.locale = 'de'

    #translate
    FastGettext._('car').should == 'Auto'
  end
end