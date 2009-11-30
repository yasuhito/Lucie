require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


module Command
  module TestCommand
    class App < Command::App; end


    class Options < Command::Option
      usage "./supermario_galactic_pizza_delivery2 [OPTIONS ...]"
      add_option( :long_option => "--help",
                  :short_option => "-h",
                  :description => "Show this help message." )
    end
  end


  describe App do
    context "when starting" do
      before :each do
        @messenger = StringIO.new
      end


      it "should show usage and exit if '--help' passed as an argument" do
        lambda do
          test_command = TestCommand::App.new( [ "--help" ], :messenger => @messenger )
        end.should raise_error( SystemExit, "exit" )

        @messenger.string.should == ( <<-EXPECTED )
usage: ./supermario_galactic_pizza_delivery2 [OPTIONS ...]

Options:
  -h, --help      Show this help message.
EXPECTED
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
