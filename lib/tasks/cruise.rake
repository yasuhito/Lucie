desc 'Continuous build target'
task :cruise do
  out = ENV[ 'CC_BUILD_ARTIFACTS' ]
  if out
    mkdir_p out unless File.directory? out
  end

  Rake::Task[ 'spec:controllers' ].invoke
  Rake::Task[ 'spec:helpers' ].invoke
#   Rake::Task[ 'spec:lib' ].invoke
#   Rake::Task[ 'spec:models' ].invoke
#   Rake::Task[ 'spec:plugins' ].invoke
#   Rake::Task[ 'spec:plugins:rspec_on_rails' ].invoke
#   Rake::Task[ 'spec:rcov' ].invoke
#   Rake::Task[ 'spec:stories' ].invoke
#   Rake::Task[ 'spec:views' ].invoke
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
