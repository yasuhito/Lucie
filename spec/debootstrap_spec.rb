require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe Debootstrap do
  before :each do | each |
    Rake::Task.clear
    @shell = mock( "shell" ).as_null_object
    SubProcess::Shell.should_receive( :open ).and_yield( @shell )
  end


  context "when deboostrap outputs to stdout" do
    it "should log (logging level = debug)" do
      @shell.should_receive( :on_stdout ).and_yield( "STDOUT" )
      Lucie::Log.should_receive( :debug ).with( "/usr/sbin/debootstrap  stable /tmp PACKAGE_REPOSITORY" )
      Lucie::Log.should_receive( :debug ).with( "STDOUT" )
      start_debootstrap
    end


    it "should log lines starting with 'E:' (logging level = error)" do
      @shell.should_receive( :on_stdout ).and_yield( "E: STDOUT" )
      Lucie::Log.should_receive( :error ).with( "E: STDOUT" )
      start_debootstrap
    end
  end


  context "when debootstrap outputs to stderr" do
    it "should log (logging level = error)" do
      @shell.should_receive( :on_stderr ).and_yield( "STDERR" )
      Lucie::Log.should_receive( :error ).with( "STDERR" )
      start_debootstrap
    end


    it "should raise if stderr matches with 'ln: xxx File exists'" do
      @shell.should_receive( :on_stderr ).and_yield( "ln: xxx File exists" )
      lambda do
        start_debootstrap
      end.should raise_error( RuntimeError, "ln: xxx File exists" )
    end
  end


  context "when debootstrap failed" do
    it "should raise" do
      @shell.should_receive( :on_stderr ).and_yield( "LAST ERROR MESSAGE" )
      @shell.should_receive( :on_failure ).and_yield
      lambda do
        start_debootstrap
      end.should raise_error( RuntimeError, "LAST ERROR MESSAGE" )
    end
  end


  def start_debootstrap
    Debootstrap.setup do | d |
      d.suite = "stable"
      d.target = "/tmp"
      d.package_repository = "PACKAGE_REPOSITORY"
      d.messenger = StringIO.new
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
