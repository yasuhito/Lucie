require File.dirname( __FILE__ ) + '/../spec_helper'


describe Platform do
  def set_stub_target_os os_name
    Config::CONFIG.stubs( :[] ).with( 'target_os' ).returns( os_name )
  end


  it 'should return OS family' do
    # given
    set_stub_target_os 'linux'

    # when, then
    Platform.family.should == 'linux'
  end


  it "should raise 'Cannot determine OS' if OS cannot be determined" do
    # given
    set_stub_target_os nil

    # when,  then
    lambda do
      Platform.family
    end.should raise_error( 'Cannot determine operating system' )
  end


  it "should raise 'Unknown OS' if OS is unknown" do
    # given
    set_stub_target_os 'UNKNOWN_OS'

    # when, then
    lambda do
      Platform.family
    end.should raise_error( 'Unknown OS: UNKNOWN_OS' )
  end


  it "should return user's name" do
    Platform.user.should_not be_nil
  end


  it 'should return a prompt string containing pwd' do
    # given
    Dir.stubs( :pwd ).returns( '/CWD' )

    # when, then
    Platform.prompt.should match( /\A\/CWD/ )
  end


  it 'should return ruby interpreter name' do
    Platform.interpreter.should_not be_nil
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
