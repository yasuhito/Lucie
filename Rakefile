#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'rake/clean'
require 'rake/testtask'
require 'rcov/rcovtask'


REQUIRE_PATHS = [ 'lib', 'test/pbar', 'test/popen3', 'test/lucie' ]


TEST_FILES = FileList[ 'test/**/ts_all.rb' ]
TEST_VERBOSITY = true


# Default Task

desc 'Default Task'
task :default => [ :rcov ]


# Test Task

desc 'Run all unit tests.'
Rake::TestTask.new( :test ) do | test |
  test.test_files = TEST_FILES
  test.libs = REQUIRE_PATHS
  test.verbose = TEST_VERBOSITY
end


# Test Coverage Task

desc 'Output a unit test coverage report'
Rcov::RcovTask.new do | test |
  test.test_files = TEST_FILES
  test.rcov_opts = [ '-xRakefile', '--text-report' ]
  test.libs = REQUIRE_PATHS
  test.verbose = TEST_VERBOSITY
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
