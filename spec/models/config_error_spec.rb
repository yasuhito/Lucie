require File.dirname( __FILE__ ) + '/../spec_helper'


describe ConfigError do
  it 'should be kind of StandardError' do
    ConfigError.new.should be_kind_of( StandardError )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
