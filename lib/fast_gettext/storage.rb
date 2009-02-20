module FastGettext
  module Storage
    [:text_domain,:available_locales].each do |method|
      define_method method do
        thread_store(method)
      end
      define_method "#{method}=" do |value|
        write_thread_store(method,value)
      end
    end

    @@text_domains={}
    def text_domains
      @@text_domains
    end

    def locale
      thread_store(:locale) || (available_locales||[]).first || 'en'
    end

    def locale=(value)
      write_thread_store(:locale,value) if not available_locales or available_locales.include?(value)
    end

    private

    def thread_store(key)
      Thread.current["FastGettext.#{key}"]
    end

    def write_thread_store(key,value)
      Thread.current["FastGettext.#{key}"]=value
    end
  end
end