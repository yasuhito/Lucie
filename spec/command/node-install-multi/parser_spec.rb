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
                   "-i", "linux-image-2.6.31.4_hongo.installer.20091022_amd64.deb",
                   "-l", "linux-image-amd64",
                   "--secret", "/home/lucie/env.enc" ]
          node_options = Parser.new( argv ).parse
          node_options[ "hongo401" ].should == ["--mac", "00:22:19:5A:33:14", "--ip-address", "10.0.1.37"]
          node_options[ "hongo402" ].should == ["--mac", "00:22:19:59:16:6C", "--ip-address", "10.0.1.38"]
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
