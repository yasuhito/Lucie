( Dir.glob( 'stories/*' ) - [ 'stories/all.rb', 'stories/helper.rb' ] ).each do | each |
  require each
end
