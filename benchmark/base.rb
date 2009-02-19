require 'rubygems'
require 'benchmark'

def locale_folder(domain)
  path = case domain
  when 'test' then File.join(File.expand_path(File.dirname(__FILE__)),'..','spec','locale')
  when 'large' then File.join(File.expand_path(File.dirname(__FILE__)),'locale')
  end

  mo = File.join(path,'de','LC_MESSAGES',"#{domain}.mo")
  raise unless File.exist?(mo)
  path
end

def results_test
  puts result {_('car') == 'Auto'}
  puts memory
end

def results_large
  puts result {_('login') == 'anmelden'}
  puts memory
end

def result
  result =Benchmark.measure do
    10_0000.times do
      raise "not translated" unless yield
    end
  end
  result
end

def memory
  pid = Process.pid
  map = `pmap -d #{pid}`
  map.split("\n").last
end