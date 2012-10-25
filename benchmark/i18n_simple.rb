require 'benchmark/base'

# Try the newest ActiveSupport first, fall back to older
begin
  require 'active_support'
rescue LoadError
  begin
    require 'activesupport'
  rescue LoadError
    puts 'To run this benchmark, please install the activesupport gem'
    exit 1
  end
end

I18n.backend = I18n::Backend::Simple.new
I18n.load_path = ['benchmark/locale/de.yml']
I18n.locale = :de
puts "ActiveSupport I18n::Backend::Simple :"
results_test{I18n.translate('activerecord.models.car')=='Auto'}
