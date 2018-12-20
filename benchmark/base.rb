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
  print "#{(result { _('login') == 'anmelden' })}s / #{memory}K / #{namespace}"
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
  (calculate_memory - @default_memory) / 1000
end

def calculate_memory
  GC.stat[:total_allocated_objects]
end

def namespace
  calculate_namespace - @default_namespace
end

def calculate_namespace
  methods.size
end

GC.start
GC.disable

@default_memory = calculate_memory
@default_namespace = calculate_namespace
