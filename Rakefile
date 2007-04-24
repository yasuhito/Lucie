#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'rake/testtask'


REQUIRE_PATHS = [ 'lib', 'test/pbar' ]


TEST_FILES = FileList[ 'test/**/ts_all.rb' ]
TEST_VERBOSITY = true


# Default Task

desc 'Default Task'
task :default => [ :test ]


# Test Task

desc 'Run all unit tests.'
Rake::TestTask.new( :test ) do | test |
  test.test_files = TEST_FILES
  test.libs = REQUIRE_PATHS
  test.verbose = TEST_VERBOSITY
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
