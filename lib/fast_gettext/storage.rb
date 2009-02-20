module FastGettext
  module Storage
    [:current_translations,:available_locales].each do |method|
      define_method method do
        thread_store(method)
      end
      define_method "#{method}=" do |value|
        write_thread_store(method,value)
      end
    end

    #global, since re-parsing whole folders takes too much time...
    @@text_domains={}
    def text_domains
      @@text_domains
    end

    def text_domain
      thread_store(:text_domain)
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

    private

    def update_current_translations
      self.current_translations = text_domains[text_domain][:mo_files][locale] || {} if text_domains[text_domain]
    end

    def thread_store(key)
      Thread.current["FastGettext.#{key}"]
    end

    def write_thread_store(key,value)
      Thread.current["FastGettext.#{key}"]=value
    end
  end
end