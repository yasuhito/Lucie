#
# $Id: package-manager.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


module InstallPackages
  module PackageManager
    def execute shell, env, command, dryRun
      if dryRun
        # [XXX] ‰½‚ç‚©‚Ì Logger ‚Åo—Í‚·‚é
        STDOUT.puts " ENV{ ``LC_ALL'' => ``C'' } #{ command.join( ' ' ) }"
      else
        shell.on_stdout do | line |
          Lucie::Log.debug line
        end
        shell.on_stderr do | line |
          Lucie::Log.error line
        end
        shell.exec env, *command
      end
    end


    def default_env
      return { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' }
    end


    def chroot_command
      return [ 'chroot', '/tmp/target' ]
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
