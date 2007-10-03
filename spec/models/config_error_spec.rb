require File.dirname( __FILE__ ) + '/../spec_helper'


describe ConfigError do
  it 'should be kind of StandardError' do
    ConfigError.new.should be_kind_of( StandardError )
  end
end
