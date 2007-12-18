require File.dirname( __FILE__ ) + '/../spec_helper'


# As a builder script
# I want to catch :reload_installer from polling scheduler
# So that I can reload installer configuration.

describe PollingScheduler, 'when starting polling scheduler' do
  before( :each ) do
    @installer = Object.new
    @polling_scheduler = PollingScheduler.new( @installer )
  end


  it 'should raise :reload_installer if configuration modified' do
    @installer.stubs( :build_if_necessary ).returns( true )

    # given
    @installer.expects( :config_modified? ).returns( true )

    # when
    # [???] throw_symbol matcher doesn't work (rspec 1.0.8)
    assert_throws( :reload_installer ) do
      @polling_scheduler.run
    end

    # then
    verify_mocks
  end
end
