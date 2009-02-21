require 'benchmark/base'

module FastestGettext
  def set_domain(folder,domain,locale)
    @data = {}
    require File.join(File.dirname(__FILE__),'..','vendor','mofile')
    FastGettext::GetText::MOFile.open(File.join(folder,locale,'LC_MESSAGES',"#{domain}.mo"), "UTF-8").each{|k,v|@data[k]=v}
  end
  def _(word)
    @data[word]
  end
end


include FastestGettext
set_domain(locale_folder('test'),'test','de')
puts "Ideal: (primitive Hash lookup)"
results_test{_('car') == 'Auto'}

#i cannot add the large file, since its an internal applications mo file
set_domain(locale_folder('large'),'large','de')
results_large