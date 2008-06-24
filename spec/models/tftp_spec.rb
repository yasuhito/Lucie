#
# tftp_spec.rb - Rspec for Tftp model.
#


require File.dirname( __FILE__ ) + '/../spec_helper'


describe Tftp do
  include FileSandbox


  before( :each ) do
    @tftp = Tftp.new
    Tftp.stubs( :new ).returns( @tftp )

    Nfsroot.stubs( :path ).returns( 'NFSROOT_PATH' )
  end


  it "should have tftpd-hpa's default configuration file path" do
    @tftp.__send__( :tftpd_default_config ).should == '/etc/default/tftpd-hpa'
  end


  describe "when node 'DUMMY_NODE is added" do
    before( :each ) do
      node = Object.new
      node.stubs( :name ).returns( 'DUMMY_NODE' )
      node.stubs( :mac_address ).returns( 'AA:BB:CC:DD:EE:FF' )

      Nodes.stubs( :find ).with( 'DUMMY_NODE' ).returns( node )
    end


    describe "and installer 'DUMMY_INSTALLER' is not built" do
      before( :each ) do
        build_statuses = Object.new
        build_statuses.stubs( :last_complete_build_status ).returns( 'never_built' )
        Installer.stubs( :new ).returns( build_statuses )
      end


      describe 'and tftpd-hpa is installed' do
        before( :each ) do
          FileTest.stubs( :exists? ).with( '/usr/sbin/in.tftpd' ).returns( true )
        end


        it 'should abort Tftp.setup' do
          lambda do
            Tftp.setup 'DUMMY_NODE', 'DUMMY_INSTALLER'
          end.should raise_error( "Installer 'DUMMY_INSTALLER' is never built." )
        end


        it 'should disable network boot with Tftp.disable' do
          in_sandbox do | sandbox |
            Configuration.stubs( :tftp_root ).returns( sandbox.root )

            Tftp.disable 'DUMMY_NODE'

            File.read( File.join( sandbox.root, 'pxelinux.cfg', '01-aa-bb-cc-dd-ee-ff' ) ).should == ( <<-EXPECTED )
default local

label local
localboot 0
EXPECTED
          end
        end


        it 'should remove network boot configuration with Tftp.remove!' do
          lambda do
            Tftp.remove! 'DUMMY_NODE'
          end.should_not raise_error
        end
      end
    end


    describe "and installer 'DUMMY_INSTALLER is added && built" do
      before( :each ) do
        build_statuses = Object.new
        build_statuses.stubs( :last_complete_build_status ).returns( 'OK' )
        Installer.stubs( :new ).returns( build_statuses )
      end


      describe 'and tftpd-hpa is installed' do
        before( :each ) do
          FileTest.stubs( :exists? ).with( '/usr/sbin/in.tftpd' ).returns( true )
        end


        it 'should disable network boot with Tftp.disable' do
          in_sandbox do | sandbox |
            Configuration.stubs( :tftp_root ).returns( sandbox.root )

            Tftp.disable 'DUMMY_NODE'

            File.read( File.join( sandbox.root, 'pxelinux.cfg', '01-aa-bb-cc-dd-ee-ff' ) ).should == ( <<-EXPECTED )
default local

label local
localboot 0
EXPECTED
          end
        end


        it 'should remove network boot configuration with Tftp.remove!' do
          lambda do
            Tftp.remove! 'DUMMY_NODE'
          end.should_not raise_error
        end


        describe 'and tftpd-hpa is up' do
          before( :each ) do
            net_tftp = Object.new
            net_tftp.stubs( :getbinary ).returns( 'OK' )
            Net::TFTP.stubs( :open ).returns( net_tftp )
          end


          it 'should generate network boot configuration with Tftp.setup' do
            in_sandbox do | sandbox |
              Configuration.stubs( :tftp_root ).returns( sandbox.root )
              @tftp.stubs( :tftpd_default_config ).returns( File.join( sandbox.root, 'CONFIG' ) )

              @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa stop' )
              @tftp.expects( :sleep ).with( 2 )
              @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

              Tftp.setup 'DUMMY_NODE', 'DUMMY_INSTALLER'

              File.read( File.join( sandbox.root, 'CONFIG' ) ).should == ( <<-EXPECTED )
RUN_DAEMON=yes
OPTIONS="-l -s #{ sandbox.root }"
EXPECTED
            end
          end
        end


        describe 'and tftpd-hpa is down' do
          before( :each ) do
            @net_tftp = Object.new
            Net::TFTP.stubs( :open ).returns( @net_tftp )
          end


          it 'should generate network boot configuration then start TFTPD with Tftp.setup if timeouted to connect to TFTPD' do
            @net_tftp.stubs( :getbinary ).raises( Net::TFTPTimeout )

            in_sandbox do | sandbox |
              Configuration.stubs( :tftp_root ).returns( sandbox.root )
              @tftp.stubs( :tftpd_default_config ).returns( File.join( sandbox.root, 'CONFIG' ) )

              @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

              lambda do
                Tftp.setup 'DUMMY_NODE', 'DUMMY_INSTALLER'
              end.should_not raise_error
            end
          end


          it 'should generate network boot configuration then stop/start TFTPD with Tftp.setup if failed to getbinary' do
            @net_tftp.stubs( :getbinary ).raises( 'getbinary failed' )

            in_sandbox do | sandbox |
              Configuration.stubs( :tftp_root ).returns( sandbox.root )
              @tftp.stubs( :tftpd_default_config ).returns( File.join( sandbox.root, 'CONFIG' ) )

              @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa stop' )
              @tftp.expects( :sleep ).with( 2 )
              @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

              lambda do
                Tftp.setup 'DUMMY_NODE', 'DUMMY_INSTALLER'
              end.should_not raise_error
            end
          end
        end
      end
    end
  end


  describe 'when tftpd-hpa is not installed' do
    before( :each ) do
      FileTest.stubs( :exists? ).with( '/usr/sbin/in.tftpd' ).returns( false )
    end


    it 'should abort Tftp.setup' do
      lambda do
        Tftp.setup 'DUMMY_NODE', 'DUMMY_INSTALLER'
      end.should raise_error( 'tftpd-hpa package is not installed. Please install first.' )
    end


    it 'should abort Tftp.disable' do
      lambda do
        Tftp.disable 'DUMMY_NODE'
      end.should raise_error( 'tftpd-hpa package is not installed. Please install first.' )
    end


    it 'should abort Tftp.remove!' do
      lambda do
        Tftp.remove! 'DUMMY_NODE'
      end.should raise_error( 'tftpd-hpa package is not installed. Please install first.' )
    end
  end


  describe "when tftpd-hpa is installed" do
    before( :each ) do
      FileTest.stubs( :exists? ).with( '/usr/sbin/in.tftpd' ).returns( true )
    end


    describe "and node 'DUMMY_NODE' is not added" do
      before( :each ) do
        Nodes.stubs( :find ).with( 'DUMMY_NODE' ).returns( nil )
      end


      it 'should fail to Tftp.setup' do
        lambda do
          Tftp.setup 'DUMMY_NODE', 'DUMMY_INSTALLER'
        end.should raise_error( "Node 'DUMMY_NODE' is not added or enabled yet." )
      end


      it 'should fail to Tftp.disable' do
        lambda do
          Tftp.disable 'DUMMY_NODE'
        end.should raise_error( "Node 'DUMMY_NODE' is not added or enabled yet." )
      end


      it 'should fail to Tftp.remove!' do
        lambda do
          Tftp.remove! 'DUMMY_NODE'
        end.should raise_error( "Node 'DUMMY_NODE' is not added or enabled yet." )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
