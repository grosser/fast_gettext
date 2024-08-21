# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'

require 'bump/tasks'
Bump.replace_in_default = Dir["gemfiles/*.lock"]

task default: :spec

desc "Run tests"
task :spec do
  sh "forking-test-runner spec --rspec --merge-coverage --quiet --no-fixtures --no-ar"
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

desc "Bundle all CMD="
task :bundle_all do
  Dir["gemfiles/*.gemfile"].each do |gemfile|
    Bundler.with_original_env { sh "BUNDLE_GEMFILE=#{gemfile} bundle #{ENV["CMD"]}" }
  end
end
