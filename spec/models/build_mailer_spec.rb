require File.dirname( __FILE__ ) + '/../spec_helper'


# [TODO] following tests makes little sense as it doesn't invoke any production code directly. How to test mailer properly?
describe BuildMailer do
  include ActionMailer::Quoting


  FIXTURES_PATH = File.dirname( __FILE__ ) + '/../fixtures'
  CHARSET = 'utf-8'


  before( :each ) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type 'text', 'plain', { 'charset' => CHARSET }
    @expected.mime_version = '1.0'
  end


  it 'should create test' do
    Time.stubs( :now ).returns( Time.at( 100000 ) )

    @expected.subject = 'Test CI E-mail'
    @expected.body = read_fixture( 'test' )
    @expected.date = Time.now
    @expected.to = 'TO'

    BuildMailer.create_test( 'TO', @expected.date ).encoded.should == @expected.encoded
  end


  it 'should create build report' do
    Time.stubs( :now ).returns( Time.at( 100000 ) )

    @expected.subject = '[Lucie] SUBJECT'
    @expected.body = read_fixture( 'build_report' )
    @expected.date = Time.now
    @expected.from = 'FROM'
    @expected.to = 'TO'

    build = Object.new
    build.stubs( :changeset ).returns( 'CHANGESET' )
    build.stubs( :output ).returns( 'OUTPUT' )
    build.stubs( :installer_settings ).returns( 'INSTALLER_SETTINGS' )

    BuildMailer.create_build_report( build, 'TO', 'FROM', 'SUBJECT', 'Message', @expected.date ).encoded.should == @expected.encoded
  end


  def read_fixture action
    IO.readlines "#{ FIXTURES_PATH }/build_mailer/#{ action }"
  end


  def encode subject
    quoted_printable subject, CHARSET
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
