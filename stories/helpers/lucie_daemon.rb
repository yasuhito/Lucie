def kill_lucied
  if lucied_pid
    system "sudo kill #{ lucied_pid }"
  end
end


def lucied_pid
  `ps ax`.split( "\n" ).each do | each |
    /(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.+)$/=~ each
    pid, tty, stat, time, command = $1.to_i, $2, $3, $4, $5
    if command == "ruby -d -e load './script/start_lucied'"
      return pid
    end
  end
  return nil
end


def lucied_pid_fn
  File.expand_path File.join( RAILS_ROOT, 'tmp', 'pids', 'lucied.pid' )
end

