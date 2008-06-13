rspec_base = File.expand_path( RAILS_ROOT + '/vendor/plugins/rspec/lib')
$LOAD_PATH.unshift( rspec_base ) if File.exist?( rspec_base )
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'spec/translator'


################################################################################
# helper methods
################################################################################


def banner task_name
  puts
  puts "*" * 80
  puts " #{ task_name }"
  puts "*" * 80
end


def run_rcov component, out
  # derived from rspec_on_rails/tasks/rspec.rake
  desc "Run all specs in #{ component } directory with RCov"
  spec_task = Spec::Rake::SpecTask.new( "lucie:rcov_#{ component }" ) do | t |
    t.spec_opts = []
    t.spec_files = FileList[ "spec/#{ component }/*_spec.rb" ]
    t.rcov = true
    if component == 'lib'
      t.rcov_opts = [ '--no-color', '--text-report', '--rails', "--exclude \"^(?!lib/)\"" ]
    else
      t.rcov_opts = [ '--no-color', '--text-report', '--rails', "--exclude \"^(?!app/#{ component })\"" ]
    end
  end
  if spec_task.spec_files.empty?
    puts "WARNING: Specs for #{ component } component is not added yet."
    return
  end
  Rake::Task[ "lucie:rcov_#{ component }" ].invoke

  if out
    outdir = "#{ out }/spec_#{ component }_coverage"
    if FileTest.directory? outdir
      sh "rm -r #{ outdir }"
    end
    mv 'coverage', outdir
  end
end


def verify_rcov component, threshold, out
  if FileTest.directory? "#{ out }/spec_#{ component }_coverage"
    RCov::VerifyTask.new( "verify_rcov_#{ component }" ) do | t |
      t.threshold = threshold
      if out
        t.index_html = "#{ out }/spec_#{ component }_coverage/index.html"
      end
    end

    Rake::Task[ "verify_rcov_#{ component }" ].invoke
  end
end


desc 'Continuous build target'
task :cruise do
  out = ENV[ 'CC_BUILD_ARTIFACTS' ]
  if out and ( not File.directory?( out ) )
    mkdir_p out
  end


  ################################################################################
  # models
  ################################################################################

  puts
  banner "MODELS"

  run_rcov 'models', out
  verify_rcov 'models', 90.6, out


  ################################################################################
  # views
  ################################################################################

  puts
  banner "VIEWS"

  run_rcov 'views', out
  verify_rcov 'views', 57.0, out


  ################################################################################
  # controllers
  ################################################################################

  puts
  banner "CONTROLLERS"

  run_rcov 'controllers', out
  verify_rcov 'controllers', 57.0, out


  ################################################################################
  # libraries
  ################################################################################

  puts
  banner "LIBRARIES"

  run_rcov 'lib', out
  verify_rcov 'lib', 72.8, out


  ################################################################################
  # helpers
  ################################################################################


  puts
  banner "HELPERS"

  run_rcov 'helpers', out
  verify_rcov 'helpers', 42.5, out


  # [TODO]
  # Rake::Task[ 'spec:plugins' ].invoke
  # Rake::Task[ 'spec:plugins:rspec_on_rails' ].invoke
  # Rake::Task[ 'spec:stories' ].invoke
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
