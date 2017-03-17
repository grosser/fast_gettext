require 'fast_gettext/cache'

module FastGettext
  # Responsibility:
  #  - store data threadsave
  #  - provide error messages when repositories are unconfigured
  #  - accept/reject locales that are set by the user
  module Storage
    class NoTextDomainConfigured < RuntimeError
      def to_s
        "Current textdomain (#{FastGettext.text_domain.inspect}) was not added, use FastGettext.add_text_domain !"
      end
    end

    [:available_locales, :_locale, :text_domain, :pluralisation_rule].each do |method_name|
      key = "fast_gettext_#{method_name}".to_sym
      define_method "#{method_name}=" do |value|
        switch_cache if Thread.current[key] != Thread.current[key]=value
      end
    end

    def _locale
      Thread.current[:fast_gettext__locale]
    end
    private :_locale, :_locale=


    def available_locales
      locales = Thread.current[:fast_gettext_available_locales] || default_available_locales
      return unless locales
      locales.map{|s|s.to_s}
    end

    # cattr_accessor with defaults
    [
      [:default_available_locales, "nil"],
      [:default_text_domain, "nil"],
      [:cache_class, "FastGettext::Cache"]
    ].each do |name, default|
      eval <<-Ruby
        @@#{name} = #{default}
        def #{name}=(value)
          @@#{name} = value
          switch_cache
        end

        def #{name}
          @@#{name}
        end
      Ruby
    end

    def text_domain
      Thread.current[:fast_gettext_text_domain] || default_text_domain
    end

    # if overwritten by user( FastGettext.pluralisation_rule = xxx) use it,
    # otherwise fall back to repo or to default lambda
    def pluralisation_rule
      Thread.current[:fast_gettext_pluralisation_rule] ||  current_repository.pluralisation_rule || lambda{|i| i!=1}
    end

    def cache
      Thread.current[:fast_gettext_cache] ||= cache_class.new
    end

    def reload!
      cache.reload!
      translation_repositories.values.each(&:reload)
    end

    #global, since re-parsing whole folders takes too much time...
    @@translation_repositories={}
    def translation_repositories
      @@translation_repositories
    end

    def current_repository
      translation_repositories[text_domain] || raise(NoTextDomainConfigured)
    end

    def key_exist?(key)
      !!(cached_find key)
    end

    def cached_find(key)
      cache.fetch(key) { current_repository[key] }
    end

    def cached_plural_find(*keys)
      key = '||||' + keys * '||||'
      cache.fetch(key) { current_repository.plural(*keys) }
    end

    def expire_cache_for(key)
      cache.delete(key)
    end

    def locale
      _locale || ( default_locale || (available_locales||[]).first || 'en' )
    end

    def locale=(new_locale)
      set_locale(new_locale)
    end

    # for chaining: puts set_locale('xx') == 'xx' ? 'applied' : 'rejected'
    # returns the current locale, not the one that was supplied
    # like locale=(), whoes behavior cannot be changed
    def set_locale(new_locale)
      new_locale = best_locale_in(new_locale)
      self._locale = new_locale
      locale
    end

    @@default_locale = nil
    def default_locale=(new_locale)
      @@default_locale = best_locale_in(new_locale)
      switch_cache
    end

    def default_locale
      @@default_locale
    end

    #Opera: de-DE,de;q=0.9,en;q=0.8
    #Firefox de-de,de;q=0.8,en-us;q=0.5,en;q=0.3
    #IE6/7 de
    #nil if nothing matches
    def best_locale_in(locales)
      formatted_sorted_locales(locales).each do |candidate|
        return candidate if not available_locales
        return candidate if available_locales.include?(candidate)
        return candidate[0..1] if available_locales.include?(candidate[0..1])#available locales include a langauge
      end
      return nil#nothing found im sorry :P
    end

    # temporarily switch locale for a block
    # FastGettext.with_locale 'xx' { _('cars') }
    def with_locale(temp_locale)
      current_locale = locale
      set_locale temp_locale
      yield
    ensure
      set_locale current_locale
    end

    #turn off translation if none was defined to disable all resulting errors
    def silence_errors
      require 'fast_gettext/translation_repository/base'
      translation_repositories[text_domain] ||= TranslationRepository::Base.new('x', :path => 'locale')
    end

    private

    # de-de,DE-CH;q=0.9 -> ['de_DE','de_CH']
    def formatted_sorted_locales(locales)
      found = weighted_locales(locales).reject{|x|x.empty?}.sort_by{|l|l.last}.reverse #sort them by weight which is the last entry
      found.flatten.map{|l| format_locale(l)}
    end

    #split the locale and seperate it into different languages
    #de-de,de;q=0.9,en;q=0.8 => [['de-de','de','0.5'], ['en','0.8']]
    def weighted_locales(locales)
      locales = locales.to_s.gsub(/\s/,'')
      found = [[]]
      locales.split(',').each do |part|
        if part =~ /;q=/ #contains language and weight ?
          found.last << part.split(/;q=/)
          found.last.flatten!
          found << []
        else
          found.last << part
        end
      end
      found
    end

    #de-de -> de_DE
    def format_locale(locale)
      if locale =~ /^([a-zA-Z]{2})[-_]([a-zA-Z]{4})$/
        locale.sub(/^([a-zA-Z]{2})[-_]([a-zA-Z]{4})$/) { $1.downcase+'_'+$2[0].upcase + $2[1..3] }
      else
        locale.sub(/^([a-zA-Z]{2,3})[-_]([a-zA-Z]{2,3})$/) { $1.downcase+'_'+$2.upcase }
      end
    end

    def switch_cache
      cache.switch_to(text_domain, locale)
    end
  end
end
