require File.dirname( __FILE__ ) + '/../spec_helper'


describe ConfigError do
  before(:each) do
    @config_error = ConfigError.new
  end


  it 'should be kind of StandardError' do
    @config_error.should be_kind_of( StandardError )
  end
end
