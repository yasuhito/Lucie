require "configuration"
require "lucie/io"
require "lucie/utils"
require "lucie/utils"
require "network_interfaces"
require "resolv"
require "ssh"


class LDB
  include Lucie::IO


  def initialize options, messenger, nic = nil
    @logger = Lucie::Log
    @options = options
    @messenger = messenger
    @nic = nic
  end


  def clone ldb_url, lucie_ip, logger
    if FileTest.exists?( local_clone_directory( ldb_url ) )
      update_local_repositories convert( ldb_url ), logger
    else
      clone_repository ldb_url, logger
      clone_clone_repository ldb_url, lucie_ip, logger
      info "LDB #{ ldb_url } cloned to local."
    end
  end


  def update_local_ldb_repository node, logger
    setup_local_ldb_directory
    ldb_dir = server_ldb_directory( node )
    unless already_cloned_to_local?( ldb_dir )
      raise "local LDB repository '#{ local_clone_directory( ldb_dir ) }' does not exist."
    end
    update_local_repositories ldb_dir, logger
    info "clone and clone-clone LDB repositories on local updated."
  end


  def install node, ldb_url, logger
    install_ldb node, ldb_url, logger
  end


  def update node, logger
    update_ldb node, logger
    info "LDB updated on node #{ node.name }."
  end


  def start node, logger
    run ssh_agent( ldb_make_command( node, node_ldb_directory( node ) ) ), @options, logger
    info "LDB executed on #{ node.name }."
  end


  def local_clone_directory ldb_url
    File.join local_ldb_directory, convert( ldb_url )
  end


  ##############################################################################
  private
  ##############################################################################


  def install_ldb node, ldb_url, logger
    run %{ssh -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } "mkdir -p /var/lib/ldb"}, @options, logger
    run "scp -i #{ SSH::PRIVATE_KEY } #{ ssh_options } -r #{ local_clone_clone_directory( ldb_url ) } root@#{ node.ip_address }:#{ checkout_directory ldb_url }", @options, logger
  end


  def update_ldb node, logger
    ldb_dir = node_ldb_directory( node )
    run ssh_agent( hg_pull_command( node, ldb_dir ) ), @options, logger
    run ssh_agent( hg_update_command( node, ldb_dir ) ), @options, logger
  end


  def server_ldb_directory node
    if dry_run
      "DUMMY_LDB_DIRECTORY"
    else
      `ssh -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } "ls -1 /var/lib/ldb"`.split( "\n" ).first
    end
  end


  def node_ldb_directory node
    if dry_run
      "DUMMY_LDB_DIRECTORY"
    else
      `ssh -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } "ls -1 /var/lib/ldb"`.split( "\n" ).first
    end
  end


  def hg_pull_command node, ldb_dir
    whoami = `whoami`.chomp
    ssh node.ip_address, "cd #{ File.join( "/var/lib/ldb", ldb_dir ) } && hg pull --ssh 'ssh -l #{ whoami } #{ ssh_options }'"
  end


  def hg_update_command node, ldb_dir
    ssh node.ip_address, "cd #{ File.join( "/var/lib/ldb", ldb_dir ) } && hg update"
  end


  def ldb_make_command node, ldb_dir
    ssh node.ip_address, "cd #{ scripts_directory( ldb_dir ) } && eval `ssh -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } #{ ldb( ldb_dir ) } env` && make"
  end


  def already_cloned_to_node? node, ldb_url, logger
    begin
      run %{ssh -A -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } "test -d #{ checkout_directory( ldb_url ) }"}, @options, logger
    rescue
      return false
    end
    true
  end


  def already_cloned_to_local? ldb_dir
    FileTest.directory? local_clone_directory( ldb_dir )
  end


  def update_local_repositories ldb_dir, logger
    [ local_clone_directory( ldb_dir ), local_clone_clone_directory( ldb_dir ) ].each do | each |
      FileUtils.cd each do
        run %{hg pull --ssh "ssh -i #{ SSH::PRIVATE_KEY }"}, @options, logger
        run %{hg update}, @options, logger
      end
    end
  end


  def clone_repository ldb_url, logger
    run %{hg clone --ssh "ssh -i #{ SSH::PRIVATE_KEY }" #{ ldb_url } #{ local_clone_directory( ldb_url ) }}, @options, logger
  end


  def clone_clone_repository ldb_url, lucie_ip, logger
    run %{hg clone --ssh "ssh -i #{ SSH::PRIVATE_KEY }" ssh://#{ lucie_ip }/#{ local_clone_directory( ldb_url ) } #{ local_clone_clone_directory( ldb_url ) }}, @options, logger
  end


  def local_clone_clone_directory ldb_url
    File.join local_ldb_directory, convert( ldb_url ) + ".local"
  end


  ##############################################################################
  # ssh helpers
  ##############################################################################


  def stdout
    @messenger || $stdout
  end


  def stderr
    @messenger || $stderr
  end


  def info message
    stdout.puts message
    @logger.info message unless dry_run
  end


  def dry_run
    @options[ :dry_run ]
  end


  def verbose
    @options[ :verbose ]
  end


  def run command, options, logger
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        stderr.puts line if verbose
        logger.debug line unless dry_run
      end
      shell.on_stderr do | line |
        next if /\AWarning: Permanently added '[^']+' \(RSA\) to the list of known hosts.\Z/=~ line
        next if /\AIdentity added: .*/=~ line
        stderr.puts line
        logger.error line unless dry_run
      end
      shell.on_failure do
        raise %{Command "#{ command }" failed}
      end

      if verbose
        stderr.puts command if verbose
        logger.debug command unless dry_run
      end
      shell.exec command unless dry_run
    end
  end


  def ssh_options
    "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  end


  def ssh_agent command
    "eval `ssh-agent`; ssh-add #{ SSH::PRIVATE_KEY }; #{ command }; ssh-agent -k"
  end


  def ssh ip, command
    %{ssh -A -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ ip } "#{ command }"}
  end


  ##############################################################################
  # misc.
  ##############################################################################


  def checkout_directory ldb_url
    File.join "/var/lib/ldb", convert( ldb_url )
  end


  def scripts_directory ldb_dir
    File.join "/var/lib/ldb", ldb_dir, "scripts"
  end


  def ldb ldb_dir
    File.join "/var/lib/ldb", ldb_dir, "bin", "ldb"
  end


  def convert url
    url.gsub( /[\/:@]/, "_" )
  end


  def setup_local_ldb_directory
    unless FileTest.directory?( local_ldb_directory )
      Lucie::Utils.mkdir_p local_ldb_directory, @options, @messenger
    end
  end


  def local_ldb_directory
    File.join Configuration.temporary_directory, "ldb"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
