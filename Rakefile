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


Cucumber::Rake::Task.new( "features_cruise", "Run Features with Cucumber (cc.rb)" ) do | t |
  rm_f rcov_dat
  t.rcov = true
  t.rcov_opts = rcov_opts
  t.cucumber_opts = "--format profile"
end


Cucumber::Rake::Task.new( "features:html", "Run Features with Cucumber (html format)" ) do | t |
  rm_f rcov_dat
  t.cucumber_opts = "--format html --out cucumber.html"
  t.rcov = true
  t.rcov_opts = rcov_opts
end


# RSpec Tasks ##################################################################

COVERAGE_THRESHOLD = 90.1


desc "Run specs with RCov"
Spec::Rake::SpecTask.new do | t |
  t.spec_files = FileList[ 'spec/**/*_spec.rb' ]
  t.spec_opts = [ "--color", "--format", "nested" ]
  t.rcov = true
  t.rcov_opts = rcov_opts
end


task :verify_rcov => [ "spec", "features" ]
RCov::VerifyTask.new do | t |
  t.threshold = COVERAGE_THRESHOLD
end


task :verify_rcov_cruise => [ "spec", "features_cruise" ]
RCov::VerifyTask.new do | t |
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
