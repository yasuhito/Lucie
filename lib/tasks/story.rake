require File.join( RAILS_ROOT, 'stories', 'helper' )


# [HACK] a monkeypatch to stop Runtime error.
# See http://www.nabble.com/Problems-with-rspec-1.1-required-inside-rake-tasks-td14693126.html
module Spec
  class << self
    def run
      true
    end
  end
end


namespace :spec do
  desc 'run all rspec stories'
  task :stories do
    Dir.glob( File.join( RAILS_ROOT, 'stories', 'helpers', '*.rb' ) ).each do | each |
      require each
    end

    steps = []
    stories = []

    if ENV[ 'STORY' ]
      # Run a story.
      # 
      # Example:
      #   % rake STORY=node:list spec:stories
      #
      component, feature = ENV[ 'STORY' ].split( ':' )
      steps << File.join( RAILS_ROOT, 'stories', 'steps', component )
      stories << File.join( RAILS_ROOT, 'stories', 'features', component, feature )
    else
      # Run all stories.
      # [XXX] This might not work !!
      #
      # Example:
      #   % rake spec:stories
      #
      Dir.glob( File.join( RAILS_ROOT, 'stories', 'steps', '*.rb' ) ).each do | each |
        steps << each
        step = File.basename( each, '.rb' )
        stories += Dir.glob( File.join( RAILS_ROOT, 'stories', 'features', step, '*[^~]' ) )
      end
    end

    steps.each do | each |
      require each
      step = File.basename( each, '.rb' )
      with_steps_for step.to_sym do
        stories.each do | story |
          run story, :type => RailsStory
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
