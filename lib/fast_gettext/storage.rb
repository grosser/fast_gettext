module FastGettext
  module Storage
    class NoTextDomainConfigured < Exception;end

    [:available_locales,:text_domain].each do |method|
      define_method method do
        thread_store(method)
      end
      define_method "#{method}=" do |value|
        write_thread_store(method,value)
      end
    end

    # speed hack, twice as fast as
    # Thread.current['FastGettext.'<<'current_translations']
    Thread.current[:fast_gettext_current_translations] = NoTextDomainConfigured
    def current_translations
      Thread.current[:fast_gettext_current_translations]
    end
    def current_translations=x
      Thread.current[:fast_gettext_current_translations]=x
    end

    #global, since re-parsing whole folders takes too much time...
    @@text_domains={}
    def text_domains
      @@text_domains
    end

    def text_domain=(new_text_domain)
      write_thread_store(:text_domain,new_text_domain)
      update_current_translations
    end

    def locale
      thread_store(:locale) || (available_locales||[]).first || 'en'
    end

    def locale=(new_locale)
      new_locale = new_locale.to_s
      if not available_locales or available_locales.include?(new_locale)
        write_thread_store(:locale,new_locale)
        update_current_translations
      end
    end

    # for chaining: puts set_locale('xx') == 'xx' ? 'applied' : 'rejected'
    # returns the current locale, not the one that was supplied
    # like locale=(), whoes behavior cannot be changed
    def set_locale(new_locale)
      self.locale = new_locale
      locale
    end

    private

    def update_current_translations
      if text_domains[text_domain]
        self.current_translations = text_domains[text_domain][:mo_files][locale] || MoFile.empty
      else
        self.current_translations = NoTextDomainConfigured
      end
    end

    def thread_store(key)
      Thread.current["FastGettext.#{key}"]
    end

    def write_thread_store(key,value)
      Thread.current["FastGettext.#{key}"]=value
    end
  end
end