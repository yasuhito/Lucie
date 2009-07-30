require "dpkg"
require "scm/hg"


class Configurator
  attr_writer :dpkg
  attr_writer :ssh

  attr_reader :scm


  def self.convert url
    url.gsub( /[\/:@]/, "_" )
  end


  def initialize scm = nil, options = {}
    @scm = scm
    @options = options
    @ssh = SSH.new( @options, messenger )
    @dpkg = Dpkg.new
  end


  def scm_installed?
    return unless @scm
    if @dpkg.installed?( @scm )
      messenger.puts "Checking #{ @scm } ... INSTALLED"
    else
      messenger.puts "Checking #{ @scm } ... NOT INSTALLED"
      raise "#{ @scm } is not installed"
    end
  end


  def clone url
    hg = Scm::Hg.new( @options )
    hg.clone url, clone_directory( url )
  end


  def install ip, url
    @ssh.cp_r ip, clone_directory( url ), client_ldb_directory
  end


  def setup ip
    unless @ssh.sh( ip, "test -d /var/lib/lucie/config" )
      @ssh.sh ip, "mkdir -p /var/lib/lucie/config"
    end
  end


  def start ip
    @ssh.sh ip, "cd #{ scripts_directory( ip ) } && eval `ssh -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ ip } #{ ldb_command( ip ) } env` && make"
  end


  ##############################################################################
  private
  ##############################################################################


  def ssh_options
    "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  end


  def ldb_command ip
    File.join client_ldb_directory, ldb_checkout_directory( ip ), "bin", "ldb"
  end


  def ldb_checkout_directory ip
    if @options[ :dry_run ]
      "DUMMY_LDB_DIR"
    else
      @ssh.sh( ip, "ls -1 /var/lib/ldb" ).split( "\n" ).first
    end
  end


  def scripts_directory ip
    File.join client_ldb_directory, ldb_checkout_directory( ip ), "scripts"
  end


  def clone_directory url
    File.join ldb_directory, Configurator.convert( url )
  end


  def client_install_directory url
    File.join client_ldb_directory, Configurator.convert( url )
  end


  def ldb_directory
    File.join Configuration.temporary_directory, "ldb"
  end


  def client_ldb_directory
    "/var/lib/lucie/config"
  end


  def messenger
    @options[ :messenger ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
