# -*- coding: utf-8 -*-
Given /^a node named "([^\"]*)"$/ do | name |
  ph_addr = '1.1.1.1'
  ph_mac = '00:00:00:00:00:00'
  Nodes.add Node.new( name, :ip_address => ph_addr, :netmask_address => '255.255.255.0', :mac_address => ph_mac )
end


Given /^a node named "([^\"]*)", with IP address "([^\"]*)"$/ do | name, address |
  ph_mac = '00:00:00:00:00:00'
  new_node = Node.new( name, :ip_address => address, :netmask_address => '255.255.255.0', :mac_address => ph_mac )
  Nodes.add new_node
end


# [FIXME] コードの重複
Given /^Lucie クライアント "([^\"]*)" \(IP アドレスは "([^\"]*)"\)$/ do | name, address |
  ph_mac = '00:00:00:00:00:00'
  Nodes.add Node.new( name, :ip_address => address, :netmask_address => '255.255.255.0', :mac_address => ph_mac )
end


Given /^a node named "([^\"]*)" with MAC address "([^\"]*)"$/ do | name, mac |
  placeholder = '1.1.1.1'
  node = Node.new( name, :mac_address => mac, :ip_address => placeholder, :netmask_address => placeholder )
  Nodes.add node
  @nodes ||= []
  @nodes << node
end


Given /^a node named "([^\"]*)", with IP address "([^\"]*)" and with MAC address "([^\"]*)"$/ do | name, address, mac |
  Nodes.add Node.new( name, :ip_address => address, :netmask_address => '255.255.255.0', :mac_address => mac )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
