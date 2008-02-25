desc 'list up all the untidy files'
task :tidy do
  list = []
  mvc = FileList[ File.join( RAILS_ROOT, 'app', '**', '*.rb' ) ]
  stories = FileList[ File.join( RAILS_ROOT, 'stories', '**', '*.rb' ) ]
  specs = FileList[ File.join( RAILS_ROOT, 'spec', '**', '*.rb' ) ]
  builder_plugins = FileList[ File.join( RAILS_ROOT, 'builder_plugins', '**', '*.rb' ) ]
  libs = FileList[ File.join( RAILS_ROOT, 'lib', '**', '*.rb' ) ]

  ( mvc + specs + stories + builder_plugins + libs ).each do | each |
    if IO.read( each ).grep( /utf-8-unix/ ).empty?
      list << each
    end
  end
  unless list.empty?
    puts "#{ list.size } file(s) are not utf-8-unix."
    list.each do | each |
      puts each
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
