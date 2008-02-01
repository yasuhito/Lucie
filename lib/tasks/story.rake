require File.join( RAILS_ROOT, 'stories', 'helper' )


namespace :spec do
  desc 'run all rspec stories'
  task :stories do
    dir = File.join( RAILS_ROOT, 'stories', 'steps' )
    Dir.entries( dir ).find_all do | f |
      f =~ /\.rb\Z/
    end.each do | file |
      step = file.match( /(\w+)\.rb\Z/ ).captures[ 0 ]
      require File.join( dir, step )
      with_steps_for step.to_sym do
        feature_dir = File.join( RAILS_ROOT, 'stories', 'features', step )
        Dir.entries( feature_dir ).reject do | f |
          ( f =~ /\A\./ ) or ( f =~ /~\Z/ )
        end.each do | story |
          run File.join( feature_dir, story ), :type => RailsStory
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
