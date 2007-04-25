#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rcov/rcovtask'


REQUIRE_PATHS = [ 'lib', 'test/pbar', 'test/popen3', 'test/lucie' ]


TEST_FILES = FileList[ 'test/**/ts_all.rb' ]
TEST_VERBOSITY = true


VERSION = '0.0.1'


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


# Gem Task

gem_spec = Gem::Specification.new do | spec |
  spec.name = 'lucie'
  spec.version = VERSION
  spec.summary = 'Lucie cluster installer program'

  spec.test_files = TEST_FILES

  spec.executables = [ 'rcS_lucie' ]

  spec.files = FileList[ 'config/*', 'lib/**/*.rb', 'bin/rcS_lucie' ]
end

Rake::GemPackageTask.new( gem_spec ) do | package |
  package.need_zip = true
  package.need_tar = true
end

desc 'Upload Lucie packages'
task :upload => [ :package ] do
  sh %{scp pkg/lucie-#{ VERSION }.{gem,tgz,zip} lucie.is.titech.ac.jp:/var/www/gemserver/gems}
  sh %{ssh lucie.is.titech.ac.jp "index_gem_repository --dir=/var/www/gemserver"}
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
