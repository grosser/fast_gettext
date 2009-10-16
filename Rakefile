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
  project_name = 'fast_gettext'
  Jeweler::Tasks.new do |gem|
    gem.name = project_name
    gem.summary = "A simple, fast and threadsafe implementation of GetText"
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{project_name}"
    gem.authors = ["Michael Grosser"]
    gem.rubyforge_project = project_name.sub('_','-')
  end

  # fake task so that rubyforge:release works
  task :rdoc do
    `mkdir rdoc`
    `echo documentation is at http://github.com/grosser/#{project_name} > rdoc/README.rdoc`
  end

  Jeweler::RubyforgeTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end