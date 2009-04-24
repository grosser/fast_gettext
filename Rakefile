desc "Run all specs in spec directory"
task :default do |t|
  options = "--colour --format progress --loadby --reverse"
  files = FileList['spec/**/*_spec.rb']
  system("spec #{options} #{files}")
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
    gem.name = "fast_gettext"
    gem.summary = "A simple, fast and threadsafe implementation of GetText"
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/fast_gettext"
    gem.authors = ["Michael Grosser"]
    gem.files += (FileList["{vendor,lib,spec}/**/*"] + FileList["VERSION.yml"] + FileList["README.markdown"]).to_a.sort
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end