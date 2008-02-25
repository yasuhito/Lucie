def kill_lucied
  if lucied_pid
    system "sudo kill #{ lucied_pid }"
  end
  system "rm -f #{ lucied_pid_fn }"
end


def lucied_pid
  `ps ax`.split( "\n" ).each do | each |
    /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.+)$/=~ each
    pid, tty, stat, time, command = $1.to_i, $2, $3, $4, $5
    if command.match( /load '\.\/script\/start_lucied'/ )
      return pid
    end
  end
  return nil
end


def lucied_pid_fn
  File.expand_path File.join( RAILS_ROOT, 'tmp', 'pids', 'lucied.pid' )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
