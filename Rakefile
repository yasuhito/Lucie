#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rcov/rcovtask'


# configuration variables
PROJECT = 'Lucie'
MY_NAME = 'Yasuhito TAKAMIYA'
MY_EMAIL = 'yasuhito@gmail.com'
PROJECT_SUMMARY = 'Lucie cluster installer program'
UNIX_NAME = 'lucie'


RUBYFORGE_USER = ENV[ 'RUBYFORGE_USER' ] || 'yasuhito'
WEBSITE_DIR = 'website'
RDOC_HTML_DIR = "#{ WEBSITE_DIR }/rdoc"


# variables we probably won't have to configure
EXT_DIR = 'ext'
HAVE_EXT = File.directory?( EXT_DIR )
EXTCONF_FILES = FileList[ "#{ EXT_DIR }/**/extconf.rb" ]
EXT_SOURCES = FileList[ "#{ EXT_DIR }/**/*.{c,h}" ]
EXT_DIST_FILES = EXT_SOURCES + EXTCONF_FILES


# automatically find the current version of the project
REQUIRE_PATHS = [ 'lib' ]
if HAVE_EXT
  REQUIRE_PATHS << EXT_DIR
end
$LOAD_PATH.concat REQUIRE_PATHS
require "#{ UNIX_NAME }"
PROJECT_VERSION = eval( "#{ PROJECT }::VERSION" )


# for rake clobber tasks.
CLOBBER.include( "#{ EXT_DIR }/**/{so,dll,o}", "#{ EXT_DIR }/**/Makefile" )
CLOBBER.include( '.config' )


GENERAL_RDOC_OPTS = {
  '--title' => "#{ PROJECT } API documentation",
  '--main' => 'README.rdoc'
}
RDOC_FILES = FileList[ 'README.rdoc', 'Changes.rdoc' ]
RDOC_FILES.include EXT_SOURCES


LIB_FILES = FileList[ 'lib/**/*.rb' ]
TEST_FILES = FileList[ 'test/**/tc_*.rb' ]
BIN_FILES = FileList[ 'bin/*' ]
DIST_FILES = FileList[ '**/*.rb', '**/*.rdoc' ]
DIST_FILES.include 'Rakefile', 'COPYING'
DIST_FILES.include BIN_FILES
DIST_FILES.include 'data/**/*', 'test/data/**/*'
DIST_FILES.exclude( /^(\.\/)?#{ RDOC_HTML_DIR }(\/|$)/ )
DIST_FILES.include EXT_DIST_FILES
DIST_FILES.exclude '**/temp_*', '**/*.tmp'
DIST_FILES.exclude( /^(\.\/)?pkg(\/|$)/ )


############################################################################
# Default Task
############################################################################
desc 'Default Task'
task :default => [ :rcov ]


############################################################################
# Test Task
############################################################################
desc 'Run all unit tests.'
test_task_name = HAVE_EXT ? 'run-tests' : 'test'
Rake::TestTask.new( test_task_name ) do | test |
  test.test_files = TEST_FILES
  test.libs = REQUIRE_PATHS
end


############################################################################
# Test Coverage Task
############################################################################
desc 'Output a unit test coverage report'
Rcov::RcovTask.new do | test |
  test.test_files = TEST_FILES
  test.libs = REQUIRE_PATHS
  test.rcov_opts = [ '-xRakefile', '--text-report' ]
end


############################################################################
# Building C extensions Task
############################################################################
CONFIG_OPTS = ENV[ 'CONFIG' ]
if HAVE_EXT
  file_create '.config' do
    ruby "setup.rb config #{ CONFIG_OPTS }"
  end

  desc "Configure and make extension. " + "The CONFIG variable is passed to `setup.rb config'"
  task 'make-ext' => '.config' do
    # The -q option suppresses messages from setup.rb
    ruby 'setup.rb -q setup'
  end

  desc 'Run tests after making the extension.'
  task 'test' do
    Rake::Task[ 'make-ext' ].invoke
    Rake::Task[ 'run-tests' ].invoke
  end
end


############################################################################
# Rdoc Task
############################################################################
Rake::RDocTask.new( 'rdoc' ) do | task |
  task.rdoc_files = RDOC_FILES + LIB_FILES
  task.title = GENERAL_RDOC_OPTS[ '--title' ]
  task.main = GENERAL_RDOC_OPTS[ '--main' ]
  task.rdoc_dir = RDOC_HTML_DIR
end


############################################################################
# Package Task
############################################################################
GEM_SPEC = Gem::Specification.new do | spec |
  spec.name = UNIX_NAME
  spec.version = PROJECT_VERSION
  spec.summary = PROJECT_SUMMARY
  spec.rubyforge_project = UNIX_NAME
  spec.homepage = "http://#{ UNIX_NAME }.rubyforge.org/"
  spec.author = MY_NAME
  spec.email = MY_EMAIL
  spec.files = DIST_FILES
  spec.test_files = TEST_FILES
  spec.executables = BIN_FILES.map do | filename |
    File.basename filename
  end
  spec.has_rdoc = true
  spec.extra_rdoc_files = RDOC_FILES
  spec.rdoc_options = GENERAL_RDOC_OPTS.to_a.flatten
  if HAVE_EXT
    spec.extensions = EXTCONF_FILES
    spec.require_paths << EXT_DIR
  end
end

Rake::GemPackageTask.new( GEM_SPEC ) do | package |
  package.need_zip = true
  package.need_tar = true
end


############################################################################
# Publishing Tasks
############################################################################
desc 'Upload website to RubyForge. scp will prompt for your RubyForge password.'
task 'pulish-website' => [ 'rdoc' ] do
  rubyforge_path = "/var/www/gforge-projects/#{ UNIX_NAME }/"
  sh "scp -r #{ WEBSITE_DIR }/* #{ RUBYFORGE_USER }@rubyforge.org:#{ rubyforge_path }", :verbose => true
end

task 'rubyforge-setup' do
  unless File.exist?( File.join( ENV[ 'HOME' ], '.rubyforge' ) )
    puts 'rubyforge will ask you to edit its config.yml now.'
    puts "Please set the `username' and `password' entries"
    puts 'to your RubyForge username and RubyForge password!'
    puts 'Press ENTER to continue.'
    $stdin.gets
    sh 'rubyforge setup', :verbose => true
  end
end

task 'rubyforge-login' => [ 'rubyforge-setup' ] do
  sh 'rubyforge login', :verbose => true
end

task 'publish-packages' => [ 'package', 'rubyforge-login' ] do
  pkg_name = ENV[ 'PKG_NAME' ] || UNIX_NAME
  cmd = "rubyforge add_release #{ UNIX_NAME } #{pkg_name} #{ PROJECT_VERSION } #{ UNIX_NAME }-#{ PROJECT_VERSION }"
  cd 'pkg' do
    sh( cmd + '.gem', :verbose => true)
    sh( cmd + '.tgz', :verbose => true)
    sh( cmd + '.zip', :verbose => true)
  end
end

# [FIXME]: merge with 'publish-package' task
task :upload => [ :package ] do
  sh %{scp pkg/lucie-#{ PROJECT_VERSION }.{gem,tgz,zip} lucie.is.titech.ac.jp:/var/www/gemserver/gems}
  sh %{ssh lucie.is.titech.ac.jp "index_gem_repository --dir=/var/www/gemserver"}
end


############################################################################
# Overaching Tasks
############################################################################
desc 'Run tests, generate RDoc and create packages.'
task 'prepare-release' => [ 'clobber' ] do
  puts "Preparing release of #{ PROJECT } version #{ VERSION }"
  Rake::Task[ 'test' ].invoke
  Rake::Task[ 'rdoc' ].invoke
  Rake::Task[ 'package' ].invoke
end

desc "Publish new release of #{ PROJECT }"
task 'publish' => [ 'prepare-release' ] do
  puts 'Uploading documentations...'
  Rake::Task[ 'publish-website' ].invoke
  puts 'Checking for rubyforge command...'
  `rubyforge --help`
  if $? == 0
    puts 'Uploading packages...'
    Rake::Task[ 'publish-packages' ].invoke
    puts 'Release done!'
  else
    puts "Can't invoke rubyforge command."
    puts "Either install rubyforge with 'gem install rubyforge'"
    puts "and retry or upload the package files manually!"
  end
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
