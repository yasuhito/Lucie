def kill_lucied
  if lucied_pid
    system "sudo kill #{ lucied_pid }"
  end
  system "rm -f #{ File.expand_path File.join( RAILS_ROOT, 'tmp', 'pids', 'lucied.pid' ) }"
end


def lucied_pid
  `ps ax -u root --format pid,command --no-headers`.split( "\n" ).each do | each |
    /^\s*(\d+) (.+)/=~ each
    pid, command = $1.to_i, $2
    if command.match /^ruby \-e load '\.\/script\/start_lucied'/
      return pid
    end
  end
  nil
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
