module FastGettext
  module Storage
    [:locale,:text_domain,:available_locales].each do |method|
      key = "FastGettext.#{method}"
      define_method method do
        Thread.current[key]
      end
      define_method "#{method}=" do |value|
        Thread.current[key] = value
      end
    end

    #NOT THREADSAFE, for speed/caching
    @@text_domains = {}
    
    def text_domains
      @@text_domains
    end

    def text_domains=(value)
      @@text_domains=value
    end
  end
end