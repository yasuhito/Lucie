require File.dirname( __FILE__ ) + '/../spec_helper'


describe NetworkInterfaces, 'when accessing network information using each iterator' do
  it 'should have interfaces for network info' do
    NetworkInterfaces.each do | each |
      lambda do
        each.netmask
      end.should_not raise_error

      lambda do
        each.ipaddress
      end.should_not raise_error

      lambda do
        each.subnet
      end.should_not raise_error
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
