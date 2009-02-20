require 'fast_gettext/mo_file'
require 'fast_gettext/storage'
require 'fast_gettext/translation'
require File.join(File.dirname(__FILE__),'..','vendor','string')

module FastGettext
  include FastGettext::Storage
  
  extend self
  def self.included(mod)  #:nodoc:
    mod.extend self
  end

  LOCALE_REX =  /^[a-z]{2}$|^[a-z]{2}_[A-Z]{2}$/
  NAMESPACE_SEPERATOR = '|'

  # users should not include FastGettext, since this would conterminate their namespace
  # rather use
  # FastGettext.locale = ..
  # FastGettext.text_domain = ..
  # and
  # include FastGettext::Translation
  FastGettext::Translation.public_instance_methods.each do |method|
    define_method method do |*args|
      Translation.send(method,*args)
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
end