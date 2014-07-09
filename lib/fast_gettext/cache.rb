module FastGettext
  class Cache
    def initialize
      @store = {}
      reload!
    end

    def fetch(key)
      translation = @current[key]
      if translation.nil? # uncached
        @current[key] = yield || false # TODO get rid of this false hack and cache :missing
      else
        translation
      end
    end

    # TODO only used for tests, maybe if-else around it ...
    def []=(key, value)
      @current[key] = value
    end

    # key performance gain:
    # - no need to lookup locale on each translation
    # - no need to lookup text_domain on each translation
    # - super-simple hash lookup
    def switch_to(text_domain, locale)
      @store[text_domain] ||= {}
      @store[text_domain][locale] ||= {}
      @store[text_domain][locale][""] = false # ignore gettext meta key when translating
      @current = @store[text_domain][locale]
    end

    def delete(key)
      @current.delete(key)
    end

    def reload!
      @current = {}
      @current[""] = false
    end
  end
end
