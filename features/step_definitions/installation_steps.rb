Then /^harddisk paratitioned$/ do
  history.should include( "Setting up hard disk partitions ..." )
end


Then /^a base system extracted$/ do
  history.should include( "Setting up Linux base system ..." )
end


Then /^GRUB configured$/ do
  history.should include( "Setting up grub ..." )
end


Then /^network settings generated$/ do
  history.should include( "Setting up network ..." )
end


Then /^a default password configured$/ do
  history.should include( "Setting up root's default password ..." )
end


Then /^SSH configured$/ do
  history.should include( "Setting up ssh ..." )
end


Then /^the node rebooted$/ do
  history.should include( "OK. Rebooting ..." )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
