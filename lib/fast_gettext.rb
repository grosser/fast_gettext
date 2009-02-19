require 'fast_gettext/mo_file'
require 'fast_gettext/storage'

module FastGettext
  include FastGettext::Storage
  
  extend self
  def self.included(mod)  #:nodoc:
    mod.extend self
  end

  LOCALE_REX =  /^[a-z]{2}$|^[a-z]{2}_[A-Z]{2}$/
  NAMESPACE_SEPERATOR = '|'

  def _(translate)
    current_mo[translate] || translate
  end

  #translate pluralized
  def n_(singular,plural,count)
    if translation = current_mo.plural(singular,plural,count)
      translation
    else
      count > 1 ? plural : singular
    end
  end

  #translate, but discard namespace if nothing was found
  # Car|Tire -> Tire if no translation could be found
  def s_(translate,seperator=nil)
    if translation = current_mo[translate]
      translation
    else
      translate.split(seperator||NAMESPACE_SEPERATOR).last
    end
  end

  def add_text_domain(name,options)
    self.text_domains ||= {}
    domain = self.text_domains[name] = {:path=>options.delete(:path),:mo_files=>{}}
    
    # parse all .mo files with the right name, that sit in locale/LC_MESSAGES folders
    Dir[File.join(domain[:path],'*')].each do |locale_folder|
      next unless File.basename(locale_folder) =~ LOCALE_REX
      mo_file = File.join(locale_folder,'LC_MESSAGES',"#{name}.mo")
      next unless File.exist? mo_file
      locale = File.basename(locale_folder)
      domain[:mo_files][locale] = MoFile.new(mo_file)
    end
    domain
  end
  
  private

  def current_mo
    mo = text_domains[text_domain][:mo_files][locale] rescue nil
    mo || {}
  end
end