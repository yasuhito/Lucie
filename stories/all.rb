( Dir.glob( 'stories/*.rb' ) - [ 'stories/all.rb', 'stories/helper.rb' ] ).each do | each |
  require each
end
