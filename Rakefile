require "rubygems"

require "cucumber/rake/task"
require "rake"
require "rake/clean"
require "rdoc/task"
require "rspec/core/rake_task"


Dir[ "tasks/**/*.rake" ].each do | t |
  load t
end

desc "Enforce Ruby code quality with static analysis of code"
task :quality => [ :reek, :roodi, :flog, :flay ]


################################################################################
# Helper methods
################################################################################

def rcov_dat
  File.join File.dirname( __FILE__ ), "coverage.dat"
end


def rcov_opts
  [ "--aggregate #{ rcov_dat }", %{--exclude /var/lib/gems,#{ File.expand_path "~/.rvm" }} ]
end


################################################################################
# Tasks
################################################################################

task :default => [ :verify_rcov ]
task :cruise => [ :verify_rcov_cruise ]


# Cucumber Tasks ###############################################################

# an alias for Emacs feature-mode.
task :features => [ :cucumber ]

Cucumber::Rake::Task.new do | t |
  rm_f rcov_dat
  t.rcov = true
  t.rcov_opts = rcov_opts
end


Cucumber::Rake::Task.new( "cucumber:cruise", "Run Features with Cucumber (cc.rb)" ) do | t |
  rm_f rcov_dat
  t.cucumber_opts = "--format progress"
  t.rcov = true
  t.rcov_opts = rcov_opts
end


# RSpec Tasks ##################################################################

COVERAGE_THRESHOLD = 94.6


desc "Run specs with RCov"
RSpec::Core::RakeTask.new do | t |
  t.rspec_opts = [ "--color" ]
  t.rcov = true
  t.rcov_opts = rcov_opts
end


desc "Run specs with RCov (cc.rb)"
RSpec::Core::RakeTask.new( "spec:cruise" ) do | t |
  t.rspec_opts = [ "--color", "--format", "profile" ]
  t.rcov = true
  t.rcov_opts = rcov_opts
end


task :verify_rcov => [ "spec", "cucumber" ]
RSpec::Core::RakeTask.new do | t |
  t.rcov = true
end


task :verify_rcov_cruise => [ "spec:cruise", "cucumber:cruise" ]
RSpec::Core::RakeTask.new do | t |
  t.rcov = true
end


# Rdoc Task ####################################################################

Rake::RDocTask.new do | t |
  t.rdoc_files.include "lib/**/*.rb"
  t.options = [ "--diagram" ]
end


# Benchmark Graph ##############################################################

task :graph do
  plot
end


def node_dirs
  Dir.glob( "./log/*" ).collect do | each |
    if ENV[ "NODES" ]
      nodes = ENV[ "NODES" ].split( /,/ )
      ( nodes.include?( File.basename( each ) ) and node_dir?( each ) ) ? each : nil
    else
      node_dir?( each ) ? each : nil
    end
  end.compact.sort
end


def node_dir? node_dir
  FileTest.directory?( node_dir ) and FileTest.exists?( latest_log( node_dir ) )
end


def latest_log node_dir
  File.join node_dir, "latest", "install.txt"
end


def parse_file log
  first_reboot = nil
  first_stage = nil
  second_reboot = nil
  second_stage = nil
  third_reboot = nil
  IO.read( log ).each_line do | l |
    case l
    when /The first reboot finished in (.*) seconds\.$/
      first_reboot = $1.to_f
    when /The first stage finished in (.*) seconds\.$/
      first_stage = first_reboot + $1.to_f
    when /The second reboot finished in (.*) seconds\.$/
      second_reboot = first_stage + $1.to_f
    when /The second stage finished in (.*) seconds\.$/
      second_stage = second_reboot + $1.to_f
    when /The third reboot finished in (.*) seconds\.$/
      third_reboot = second_stage + $1.to_f
    else
      # skip
    end
  end
  if first_reboot.nil? or first_stage.nil? or second_reboot.nil? or second_stage.nil? or third_reboot.nil?
    raise "failed to parse #{ log }"
  end
  { :first_reboot => first_reboot, :first_stage => first_stage,
    :second_reboot => second_reboot, :second_stage => second_stage,
    :third_reboot => third_reboot }
end


def parse
  result = {}
  node_dirs.each do | each |
    node_name = File.basename( each )
    begin
      result[ node_name ] = parse_file( latest_log( each ) )
      $stderr.puts "Succeeded in parsing #{ node_name }'s latest log."
    rescue
      $stderr.puts "Warning: failed to parse #{ node_name }'s latest log. Skipping ..."
    end
  end
  result
end


def gen_plot plot_file, eps_file
  data = parse
  File.open( plot_file, "w" ) do | f |
    f.puts "# arrow styles"
    f.puts "set style arrow 1 heads size screen 0.002, 90 lt 2 lw 1 front"
    f.puts "set style arrow 2 heads size screen 0.002, 90 lt 1 lw 1 front"
    f.puts "set style arrow 3 heads size screen 0.002, 90 lt 3 lw 1 front"
    f.puts "set style arrow 4 heads size screen 0.002, 90 lt 4 lw 1 front"
    f.puts "set style arrow 5 heads size screen 0.002, 90 lt 5 lw 1 front"
    f.puts

    nnodes = 1
    arrow = 1
    xrange = 0
    data.keys.sort.each do | each |
      perf = data[ each ]
      f.puts "# #{ each }"
      f.puts "set arrow #{ arrow } from 0,#{ nnodes } to #{ perf[ :first_reboot ] },#{ nnodes } as 1"; arrow += 1
      f.puts "set arrow #{ arrow } from #{ perf[ :first_reboot ] },#{ nnodes } to #{ perf[ :first_stage ] },#{ nnodes } as 2"; arrow += 1
      f.puts "set arrow #{ arrow } from #{ perf[ :first_stage ] },#{ nnodes } to #{ perf[ :second_reboot ] },#{ nnodes } as 3"; arrow += 1
      f.puts "set arrow #{ arrow } from #{ perf[ :second_reboot ] },#{ nnodes } to #{ perf[ :second_stage ] },#{ nnodes } as 4"; arrow += 1
      f.puts "set arrow #{ arrow } from #{ perf[ :second_stage ] },#{ nnodes } to #{ perf[ :third_reboot ] },#{ nnodes } as 5"; arrow += 1
      xrange = perf[ :third_reboot ] if perf[ :third_reboot ] > xrange
      nnodes += 1
    end
    f.puts
    
    f.puts <<-EOF
# graph definitions
set xlabel "time"
set ylabel "node"
set title "Installation Progress"
set terminal postscript eps dashed color
set out "#{ eps_file }"
plot [0:#{ xrange + 10 }] [0:#{ nnodes }] 0 notitle
EOF
  end
end


PLOT_FILE = "bench.plot"
EPS_FILE = "bench.eps"


def plot
  gen_plot PLOT_FILE, EPS_FILE
  system "gnuplot < #{ PLOT_FILE }"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
