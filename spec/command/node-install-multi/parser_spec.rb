require File.join( File.dirname( __FILE__ ), "..", "..", "spec_helper" )


module Command
  module NodeInstallMulti
    describe Parser do
      context "when parsing commandline options" do
        it "should parse argv properly" do
          argv = [ "hongo401 --mac 00:22:19:5A:33:14 --ip-address 10.0.1.37",
                   "hongo402 --mac 00:22:19:59:16:6C --ip-address 10.0.1.38",
                   "--storage-conf", "/home/lucie/disk6_swap24_nopreserve",
                   "--netmask", "255.255.0.0",
                   "--source-control", "Subversion",
                   "--suite", "etch",
                   "--ldb-repository", "svn+ssh://intri@myrepos.org/SVN/L4",
                   "--verbose",
                   "-l", "linux-image-amd64",
                   "--secret", "/home/lucie/env.enc" ]
          node_options = Parser.new( argv, Command::NodeInstallMulti::Options.new.parse( argv ) ).parse

          hongo401 = node_options[ "hongo401" ]
          hongo401.mac.should == "00:22:19:5A:33:14"
          hongo401.ip_address.should == "10.0.1.37"
          hongo401.storage_conf.should == "/home/lucie/disk6_swap24_nopreserve"
          hongo401.netmask.should == "255.255.0.0"
          hongo401.suite.should == "etch"
          hongo401.linux_image.should == "linux-image-amd64"

          hongo402 = node_options[ "hongo402" ]
          hongo402.mac.should == "00:22:19:59:16:6C"
          hongo402.ip_address.should == "10.0.1.38"
          hongo402.storage_conf.should == "/home/lucie/disk6_swap24_nopreserve"
          hongo402.netmask.should == "255.255.0.0"
          hongo402.suite.should == "etch"
          hongo402.linux_image.should == "linux-image-amd64"
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
