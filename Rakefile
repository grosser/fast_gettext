desc "Run all specs in spec directory"
task :default do |t|
  options = "--colour --format progress --loadby --reverse"
  files = FileList['spec/**/*_spec.rb']
  system("spec #{options} #{files}")
end

task :benchmark do
  puts `ruby benchmark/original.rb`
  puts `ruby benchmark/fast_gettext.rb`
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "fast_gettext"
    gem.summary = "A simple, fast and threadsafe implementation of GetText"
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/fast_gettext"
    gem.authors = ["Michael Grosser"]
    gem.files += FileList["{lib,vendor,spec,benchmark}/**/*,[A-Z]+"]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end