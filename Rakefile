task :default do
  sh "AR='~>2' && (bundle || bundle install) && bundle exec rspec spec" # ActiveRecord 2
  sh "AR='~>3' && (bundle || bundle install) && bundle exec rspec spec" # ActiveRecord 3
end

task :benchmark do
  puts "Running on #{RUBY}"
  %w[baseline ideal fast_gettext original i18n_simple].each do |bench|
    puts `ruby benchmark/#{bench}.rb`
    puts ""
  end
end

task :namespaces do
  puts `ruby benchmark/namespace/original.rb`
  puts `ruby benchmark/namespace/fast_gettext.rb`
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'fast_gettext'
    gem.summary = "A simple, fast, memory-efficient and threadsafe implementation of GetText"
    gem.email = "michael@grosser.it"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
