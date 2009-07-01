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
    setup_local_ldb_directory
    if already_cloned_to_local?( ldb_url )
      update_local_repositories ldb_url, logger
      info "clone and clone-clone LDB repositories on local updated."
    else
      clone_repository ldb_url, logger
      clone_clone_repository ldb_url, lucie_ip, logger
      info "LDB #{ ldb_url } cloned to local."
    end
  end


  def update node, ldb_url, logger
    if already_cloned_to_node?( node, ldb_url, logger )
      update_ldb node, ldb_url, logger
    else
      install_ldb node, ldb_url, logger
    end
    info "LDB updated on node #{ node.name }."
  end


  def start node, ldb_url, logger
    run ssh_agent( ldb_make_command( node, ldb_url ) ), @options, logger
    info "LDB executed on #{ node.name }."
  end


  def local_clone_directory ldb_url
    return unless ldb_url
    File.join local_ldb_directory, convert( ldb_url )
  end


  ##############################################################################
  private
  ##############################################################################


  def install_ldb node, ldb_url, logger
    run %{ssh -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } "mkdir -p /var/lib/ldb"}, @options, logger
    run "scp -i #{ SSH::PRIVATE_KEY } #{ ssh_options } -r #{ local_clone_clone_directory( ldb_url ) } root@#{ node.ip_address }:#{ checkout_directory ldb_url }", @options, logger
  end


  def update_ldb node, ldb_url, logger
    run ssh_agent( hg_pull_command( node, ldb_url ) ), @options, logger
    run ssh_agent( hg_update_command( node, ldb_url ) ), @options, logger
  end


  def hg_pull_command node, ldb_url
    whoami = `whoami`.chomp
    ssh node.ip_address, "cd #{ checkout_directory( ldb_url ) } && hg pull --ssh 'ssh -l #{ whoami } #{ ssh_options }'"
  end


  def hg_update_command node, ldb_url
    ssh node.ip_address, "cd #{ checkout_directory( ldb_url ) } && hg update"
  end


  def ldb_make_command node, ldb_url
    ssh node.ip_address, "cd #{ make_directory( ldb_url ) } && eval `ssh -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } #{ ldb( ldb_url ) } env` && make"
  end


  def already_cloned_to_node? node, ldb_url, logger
    begin
      run %{ssh -A -i #{ SSH::PRIVATE_KEY } #{ ssh_options } root@#{ node.ip_address } "test -d #{ checkout_directory( ldb_url ) }"}, @options, logger
    rescue
      return false
    end
    true
  end


  def already_cloned_to_local? ldb_url
    FileTest.directory? local_clone_directory( ldb_url )
  end


  def update_local_repositories ldb_url, logger
    [ local_clone_directory( ldb_url ), local_clone_clone_directory( ldb_url ) ].each do | each |
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


  def make_directory ldb_url
    File.join checkout_directory( ldb_url ), "scripts"
  end


  def ldb ldb_url
    File.join checkout_directory( ldb_url ), "bin", "ldb"
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
