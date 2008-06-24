require File.dirname( __FILE__ ) + '/../spec_helper'


describe NetworkInterfaces, 'when accessing network information using each iterator' do
  it 'should have interfaces for network info' do
    NetworkInterfaces.each do | each |
      each.netmask.should_not be_nil
      each.ipaddress.should_not be_nil
      each.subnet.should_not be_nil
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
