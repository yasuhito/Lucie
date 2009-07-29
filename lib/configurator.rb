require "dpkg"


module Scm
  class Hg
    def initialize options
      @dry_run = options[ :dry_run ]
      @verbose = options[ :verbose ]
      @messenger = options[ :messenger ]
    end


    def clone url, target
      run %{hg clone --ssh "ssh -i #{ SSH::PRIVATE_KEY }" #{ url } #{ target }}
    end


    def run command
      Popen3::Shell.open do | shell |
        @messenger.puts command if @verbose
        shell.exec command unless @dry_run
      end
    end
  end
end


class Configurator
  attr_writer :dpkg
  attr_reader :scm


  def initialize scm = nil, options = {}
    @scm = scm
    @dry_run = options[ :dry_run ]
    @verbose = options[ :verbose ]
    @messenger = options[ :messenger ]
    @dpkg = Dpkg.new
  end


  def scm_installed?
    return unless @scm
    if @dpkg.installed?( @scm )
      @messenger.puts "Checking #{ @scm } ... INSTALLED"
    else
      @messenger.puts "Checking #{ @scm } ... NOT INSTALLED"
      raise "#{ @scm } is not installed"
    end
  end


  def clone url
    hg = Scm::Hg.new( :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger )
    hg.clone url, clone_directory( url )
  end


  def clone_directory url
    File.join ldb_directory, convert( url )
  end


  def ldb_directory
    File.join Configuration.temporary_directory, "ldb"
  end


  def convert url
    url.gsub( /[\/:@]/, "_" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
