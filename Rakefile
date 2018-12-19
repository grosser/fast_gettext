# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'wwtd/tasks'

desc "Run test matrix as defined in .travis.yml on current ruby"
task default: "wwtd:local"

desc "Run tests"
task :spec do
  sh "rspec spec"
end

desc "Benchmark different translation frameworks"
task :benchmark do
  puts "Running on #{RUBY_DESCRIPTION}"
  Bundler.with_original_env do
    ["baseline", "ideal", "fast_gettext", "original", "i18n_simple"].each do |bench|
      sh "ruby ./benchmark/#{bench}.rb"
      puts
    end
  end
end

desc "Show namespace differences between translation frameworks"
task :namespaces do
  sh "ruby benchmark/namespace/original.rb"
  sh "ruby benchmark/namespace/fast_gettext.rb"
end

desc "Check code against ruby style guide"
task :rubocop do
  sh "rubocop"
end
