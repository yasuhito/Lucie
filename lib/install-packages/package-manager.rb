module InstallPackages
  module PackageManager
    def execute shell, command, options
      if options.dry_run
        env_string = []
        apt_env( options.http_proxy )[ :env ].each do | key, value |
          env_string << "'#{ key }' => '#{ value }'"
        end
        STDOUT.puts "ENV{ #{ env_string.join( ', ' ) } }, '#{ command }'"
      else
        shell.on_stdout do | line |
          Lucie::Log.debug line
        end
        shell.on_stderr do | line |
          Lucie::Log.debug line
        end
        shell.exec command, apt_env( options.http_proxy )
      end
    end


    def apt_env http_proxy
      if http_proxy
        return { :env => { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive', 'http_proxy' => http_proxy } }
      else
        return { :env => { 'LC_ALL' => 'C', 'DEBIAN_FRONTEND' => 'noninteractive' } }
      end
    end


    def chroot_command
      return 'chroot /tmp/target'
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
