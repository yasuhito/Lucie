require File.dirname( __FILE__ ) + '/../spec_helper'


describe InstallersController do
  it 'should route /installers to /' do
    route_for( :controller => 'installers', :action => 'index' ).should == '/'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

