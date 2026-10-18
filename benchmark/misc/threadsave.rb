# frozen_string_literal: true

require 'benchmark'
def test(baseline = defined?(BASELINE) ? BASELINE : 0, &block)
  result = Benchmark.measure { 1_000_000.times(&block) }
  result.to_s.strip.split.first.to_f - baseline
end

BASELINE = test { nil }
Thread.current[:library_name] = {}
other = "x"
puts "Ruby #{RUBY_VERSION}"

puts "generic:"
puts "  Symbol: #{test { Thread.current[:library_name][:just_a_symbol] }}s"
puts "  String concat: #{test { Thread.current[+'xxxxxx' << other.to_s] }}s"
puts "  String add: #{test { Thread.current['xxxxxx' + other.to_s] }}s" # rubocop:disable Style/StringConcatenation
puts "  String insert: #{test { Thread.current["xxxxxx#{other}"] }}s"

puts "single:"
puts "  Symbol: #{test { Thread.current[:long_unique_symbol] }}s"
puts "  String: #{test { Thread.current['xxxxxx'] }}s"
