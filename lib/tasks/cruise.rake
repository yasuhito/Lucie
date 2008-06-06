rspec_base = File.expand_path( RAILS_ROOT + '/vendor/plugins/rspec/lib')
$LOAD_PATH.unshift( rspec_base ) if File.exist?( rspec_base )
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'spec/translator'


def banner task_name
  puts
  puts "*" * 80
  puts " #{ task_name }"
  puts "*" * 80
end


# derived from rspec_on_rails/tasks/rspec.rake
namespace :lucie do
  desc "Run all specs in spec directory with RCov"
  Spec::Rake::SpecTask.new( :rcov ) do | t |
    t.spec_opts = []
    t.spec_files = FileList[ 'spec/**/*_spec.rb','spec/**/*_test.rb' ]
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines( "#{ RAILS_ROOT }/spec/rcov.opts" ).map do | l |
        l.chomp.split " "
      end.flatten
    end
  end
end


desc 'Continuous build target'
task :cruise do
  out = ENV[ 'CC_BUILD_ARTIFACTS' ]
  if out and ( not File.directory?( out ) )
    mkdir_p out
  end

  Rake::Task[ 'lucie:rcov' ].invoke
  if out
    mv 'coverage', "#{ out }/spec coverage"
  end

  RCov::VerifyTask.new( :cruise_verify_rcov ) do | t |
    t.threshold = 85.8
    if out
      t.index_html = "#{ out }/spec coverage/index.html"
    end
  end

  banner "spec:models"
  Rake::Task[ 'spec:models' ].invoke

  banner "spec:views"
  Rake::Task[ 'spec:views' ].invoke

  banner "spec:controllers"
  Rake::Task[ 'spec:controllers' ].invoke

  banner "spec:lib"
  Rake::Task[ 'spec:lib' ].invoke

  banner "spec:helpers"
  Rake::Task[ 'spec:helpers' ].invoke

  banner "spec:plugins"
  Rake::Task[ 'spec:plugins' ].invoke
  # Rake::Task[ 'spec:plugins:rspec_on_rails' ].invoke
  # Rake::Task[ 'spec:stories' ].invoke

  puts
  puts "RSpec tests finished."
  puts

  Rake::Task[ 'cruise_verify_rcov' ].invoke
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
