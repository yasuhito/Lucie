require "rubygems"

require "cucumber/rake/task"
require "hanna/rdoctask"
require "rake"
require "rake/clean"
require "spec/rake/spectask"
require "spec/rake/verify_rcov"


################################################################################
# Helper methods
################################################################################


def rcov_dat
  File.join File.dirname( __FILE__ ), "coverage.dat"
end


def rcov_opts
  [ "--aggregate #{ rcov_dat }", "--exclude /var/lib/gems,lib/popen3.rb,lib/pshell.rb,spec/" ]
end


################################################################################
# Tasks
################################################################################


task :default => [ :verify_rcov ]
task :cruise => [ :verify_rcov_cruise ]


# Cucumber Tasks ###############################################################

Cucumber::Rake::Task.new do | t |
  rm_f rcov_dat
  t.rcov = true
  t.rcov_opts = rcov_opts
end


Cucumber::Rake::Task.new( "cucumber:cruise", "Run Features with Cucumber (cc.rb)" ) do | t |
  rm_f rcov_dat
  t.cucumber_opts = "--format profile"
  t.rcov = true
  t.rcov_opts = rcov_opts
end


# RSpec Tasks ##################################################################

COVERAGE_THRESHOLD = 93.2


desc "Run specs with RCov"
Spec::Rake::SpecTask.new do | t |
  t.spec_files = FileList[ 'spec/**/*_spec.rb' ]
  t.spec_opts = [ "--color", "--format", "nested" ]
  t.rcov = true
  t.rcov_opts = rcov_opts
end


desc "Run specs with RCov (cc.rb)"
Spec::Rake::SpecTask.new( "spec:cruise" ) do | t |
  t.spec_files = FileList[ 'spec/**/*_spec.rb' ]
  t.spec_opts = [ "--color", "--format", "profile" ]
  t.rcov = true
  t.rcov_opts = rcov_opts
end


task :verify_rcov => [ "spec", "cucumber" ]
RCov::VerifyTask.new do | t |
  t.threshold = COVERAGE_THRESHOLD
end


task :verify_rcov_cruise => [ "spec:cruise", "cucumber:cruise" ]
RCov::VerifyTask.new( :verify_rcov_cruise ) do | t |
  t.threshold = COVERAGE_THRESHOLD
end


# Rdoc Task ####################################################################

Rake::RDocTask.new do | t |
  t.rdoc_files.include "lib/**/*.rb"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
