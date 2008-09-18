require File.dirname( __FILE__ ) + '/../spec_helper'


describe Subversion do
  include FileSandbox


  before( :each ) do
    @subversion = Subversion.new( :url => 'http://www.my.com/', :username => 'USERNAME', :password => 'PASSWORD' )
  end


  describe 'when creating Subversion object' do
    it 'should raise if unknown option passed' do
      lambda do
        Subversion.new( :unknown_option => 'foobar' )
      end.should raise_error( "don't know how to handle 'unknown_option'" )
    end
  end


  describe 'when checking out' do
    it 'should exec svn command without --revision option' do
      in_sandbox do | sandbox |
        @subversion.expects( :sh_exec ).with( "svn --non-interactive co http://www.my.com/ #{ sandbox.root } --username USERNAME --password PASSWORD" )
        
        lambda do
          @subversion.checkout sandbox.root
        end.should_not raise_error
      end
    end


    it 'should exec svn command with --revision option' do
      in_sandbox do | sandbox |
        @subversion.expects( :sh_exec ).with( "svn --non-interactive co http://www.my.com/ #{ sandbox.root } --username USERNAME --password PASSWORD --revision 1" )
        
        lambda do
          @subversion.checkout sandbox.root, 1
        end.should_not raise_error
      end
    end


    it 'should raise if url not specified' do
      in_sandbox do | sandbox |
        @subversion.url = nil

        lambda do
          @subversion.checkout sandbox.root
        end.should raise_error( 'URL not specified' )
      end
    end
  end


  describe 'when getting revisions' do
    it 'should get latest revision number' do
      @subversion.expects( :execute_in_local_copy ).times( 2 ).returns( info_entry.split( "\n" ), log_entry.split( "\n" ) )

      revision = @subversion.latest_revision( dummy_installer )

      assert_equal 18, revision.number
    end


    it 'should get recent revisions' do
      revisions = [ Revision.new( 1 ), revision_one = Revision.new( 2 ), revision_one = Revision.new( 3 ) ]
      @subversion.expects( :execute_in_local_copy ).with( 'INSTALLER', 'svn --non-interactive log --revision HEAD:1 --verbose --xml' ).returns( 'SVN_OUTPUT' )
      SubversionLogParser.any_instance.expects( :parse_log ).with( 'SVN_OUTPUT' ).returns( revisions )

      new_revisions = @subversion.revisions_since( 'INSTALLER', 1 )

      new_revisions.size.should == 2
      new_revisions[ 0 ].number.should == 3
      new_revisions[ 1 ].number.should == 2
    end
  end


  describe 'when updating repository' do
    it 'should update to HEAD if revision number not specified' do
      @subversion.expects( :execute_in_local_copy ).with( 'INSTALLER', 'svn --non-interactive update --revision HEAD' ).returns( 'SVN_OUTPUT' )
      SubversionLogParser.any_instance.expects( :parse_update ).with( 'SVN_OUTPUT' )
      
      lambda do
        @subversion.update 'INSTALLER'
      end.should_not raise_error
    end


    it 'should update to specified revision number' do
      @subversion.expects( :execute_in_local_copy ).with( 'INSTALLER', 'svn --non-interactive update --revision 10' ).returns( 'SVN_OUTPUT' )
      SubversionLogParser.any_instance.expects( :parse_update ).with( 'SVN_OUTPUT' )
      
      lambda do
        @subversion.update 'INSTALLER', Revision.new( 10 )
      end.should_not raise_error
    end
  end


  describe 'when error occured' do
    it 'should raise if initialized with unknown option' do
      lambda do
        Subversion.new :unknown_option => true
      end.should raise_error
    end
  end


  ################################################################################
  # Helpers
  ################################################################################


  DummyInstaller = Struct.new :local_checkout, :path


  def dummy_installer
    DummyInstaller.new '.', '.'
  end


  def info_entry
    <<-EOF
<?xml version="1.0"?>
<info>
<entry kind="dir" path="." revision="10">
<url>https://lucie.is.titech.ac.jp/svn/trunk</url>
<repository>
  <root>https://lucie.is.titech.ac.jp/svn</root>
  <uuid>67f3d07d-cb8c-4aff-9cba-f81f45f607f3</uuid>
</repository>
<wc-info>
  <schedule>normal</schedule>
</wc-info>
<commit revision="10">
  <author>alexey</author>
  <date>2007-10-02T01:24:20.295589Z</date>
</commit>
</entry>
</info>
EOF
  end


  def log_entry
    <<-EOF
<log>
<logentry revision="18">
  <author>alexey</author>
  <date>2006-01-11T13:58:58.000007Z</date>
  <msg>Goofin around with integration test for the builder</msg>
</logentry>
<logentry revision="17">
  <author>alexey</author>
  <date>2006-01-11T12:44:54.000007Z</date>
  <msg>Moved builder from vendor, made bulder's integration tests talk to a subversion repository in the local file system</msg>
</logentry>
<logentry revision="15">
  <author>stellsmi</author>
  <date>2006-01-11T10:37:32.000007Z</date>
  <msg>integration test does a checkout</msg>
</logentry>
</log>
EOF
#'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
