rspec_base = File.expand_path( RAILS_ROOT + '/vendor/plugins/rspec/lib')
$LOAD_PATH.unshift( rspec_base ) if File.exist?( rspec_base )
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'spec/translator'


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


RCov::VerifyTask.new( :cruise_verify_rcov ) do | t |
  t.threshold = 85.8
  t.index_html = "./spec coverage/index.html"
end


desc 'Continuous build target'
task :cruise do
  out = ENV[ 'CC_BUILD_ARTIFACTS' ]
  if out
    mkdir_p out unless File.directory? out
  end

  Rake::Task[ 'lucie:rcov' ].invoke
  if out
    mv 'coverage', "#{ out }/spec coverage"
  end

  Rake::Task[ 'spec:models' ].invoke
  Rake::Task[ 'spec:views' ].invoke
  Rake::Task[ 'spec:controllers' ].invoke
  Rake::Task[ 'spec:lib' ].invoke
  Rake::Task[ 'spec:helpers' ].invoke
  Rake::Task[ 'spec:plugins' ].invoke
  # Rake::Task[ 'spec:plugins:rspec_on_rails' ].invoke
  # Rake::Task[ 'spec:stories' ].invoke

  Rake::Task[ 'cruise_verify_rcov' ].invoke
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
