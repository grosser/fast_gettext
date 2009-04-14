module FastGettext
  # Responsibility:
  #  - store data threadsave
  #  - provide error messages when repositories are unconfigured
  #  - accept/reject locales that are set by the user
  module Storage
    class NoTextDomainConfigured < RuntimeError
      def to_s
        "Current textdomain (#{FastGettext.text_domain.inspect}) was not added, use FastGettext.add_text_domain!"
      end
    end

    [:available_locales, :_locale, :text_domain].each do |method_name|
      key = "fast_gettext_#{method_name}".to_sym
      define_method method_name do
        Thread.current[key]
      end

      define_method "#{method_name}=" do |value|
        Thread.current[key]=value
        update_current_cache
      end
    end
    private :_locale, :_locale=

    def text_domain
      Thread.current[:fast_gettext_text_domain] || default_text_domain
    end

    def current_cache
      Thread.current[:fast_gettext_current_cache] || {}
    end

    def current_cache=(cache)
      Thread.current[:fast_gettext_current_cache] = cache
    end

    #-> cattr_accessor :default_text_domain
    @@default_text_domain = nil
    def default_text_domain=(domain)
      @@default_text_domain = domain
      update_current_cache
    end

    def default_text_domain
      @@default_text_domain
    end

    #global, since re-parsing whole folders takes too much time...
    @@translation_repositories={}
    def translation_repositories
      @@translation_repositories
    end

    # used to speedup simple translations, does not work for pluralisation
    # caches[text_domain][locale][key]=translation
    @@caches={}
    def caches
      @@caches
    end

    def current_repository
      translation_repositories[text_domain] || raise(NoTextDomainConfigured)
    end

    def locale
      _locale || ( default_locale || (available_locales||[]).first || 'en' )
    end

    def locale=(new_locale)
      new_locale = best_locale_in(new_locale)
      self._locale = new_locale if new_locale
    end

    # for chaining: puts set_locale('xx') == 'xx' ? 'applied' : 'rejected'
    # returns the current locale, not the one that was supplied
    # like locale=(), whoes behavior cannot be changed
    def set_locale(new_locale)
      self.locale = new_locale
      locale
    end
    
    @@default_locale = nil
    def default_locale=(new_locale)
      new_locale = best_locale_in(new_locale)
      @@default_locale = new_locale
      update_current_cache
    end

    def default_locale
      @@default_locale
    end

    #Opera: de-DE,de;q=0.9,en;q=0.8
    #Firefox de-de,de;q=0.8,en-us;q=0.5,en;q=0.3
    #IE6/7 de
    #nil if nothing matches
    def best_locale_in(locales)
      locales = locales.to_s.gsub(/\s/,'')

      #split the locale and seperate it into different languages
      #[['de-de','de','0.5'], ['en','0.8'], ...]
      parts = locales.split(',')
      locales = [[]]
      parts.each do |part|
        locales.last << part.split(/;q=/)#add another language or language and weight
        locales += [] if part.length == 2 #if it could be split we are now in a new locale
      end

      locales = locales.sort_by{|l|l.last} #sort them by weight which is the last entry
      locales.flatten.each do |candidate|
        candidate = candidate.sub(/^([a-zA-Z]{2})[-_]([a-zA-Z]{2})$/){$1.downcase+'_'+$2.upcase}#de-de -> de_DE
        return candidate if not available_locales or available_locales.include?(candidate)
      end
      return nil#nothing found im sorry :P
    end

    #turn off translation if none was defined to disable all resulting errors
    def silence_errors
      require 'fast_gettext/translation_repository/base'
      translation_repositories[text_domain] = TranslationRepository::Base.new('x')
    end

    private

    def update_current_cache
      caches[text_domain] ||= {}
      caches[text_domain][locale] ||= {}
      self.current_cache = caches[text_domain][locale]
    end
  end
end