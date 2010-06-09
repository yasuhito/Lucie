When /^I run first stage installer with node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  node = Nodes.find( name )
  node.status = Status::Installer.new( "/tmp/lucie/log", :dry_run => true, :messenger => @messenger )
  install_options = { :base_system => "base.tgz", :storage_conf => "./my_storage.conf", :ldb_directory => "LDB_DIRECTORY", :arch => "i386" }
  logger = Lucie::Logger::Installer.new( "/tmp/lucie/log/", debug_options )

  first_stage = FirstStage.new( Nodes.find( name ), install_options, logger, :dry_run => true, :messenger => @messenger, :nic => [ @if ] )
  first_stage.run
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
