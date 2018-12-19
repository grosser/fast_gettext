# frozen_string_literal: true

require 'benchmark'
$LOAD_PATH.unshift 'lib'

RUNS = 500_000

def locale_folder(domain)
  path =
    case domain
    when 'test' then File.join(__dir__, '..', 'spec', 'locale')
    when 'large' then File.join(__dir__, 'locale')
    end

  mo = File.join(path, 'de', 'LC_MESSAGES', "#{domain}.mo")
  raise unless File.exist?(mo)

  path
end

def results_test(&block)
  print "#{result(&block)}s / #{memory}K <-> "
end

def results_large
  print "#{(result { _('login') == 'anmelden' })}s / #{memory}K"
  puts ""
end

def result
  Benchmark.realtime do
    RUNS.times do
      raise "not translated" unless yield
    end
  end.round(2)
end

def memory
  (GC.stat[:total_allocated_objects] - @default_memory) / 1000
end

GC.start
GC.disable

@default_memory = GC.stat[:total_allocated_objects]
