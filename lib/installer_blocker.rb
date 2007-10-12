class InstallerBlocker
  @@pid_files = {}


  def self.block(installer)
    raise already_locked_error_message(installer) if @@pid_files.include?(pid_file(installer))
    lock = File.open(pid_file(installer), 'w')
    locked = lock.flock(File::LOCK_EX | File::LOCK_NB)
    if locked
      @@pid_files[pid_file(installer)] = lock
    else
      lock.close
      raise cannot_lock_error_message( installer )
    end
  end


  def self.blocked?(installer)
    return true if @@pid_files.include?(pid_file(installer))

    lock = File.open(pid_file(installer), 'w')
    begin
      return !lock.flock(File::LOCK_EX | File::LOCK_NB)
    ensure
      lock.flock(File::LOCK_UN | File::LOCK_NB)
      lock.close
    end
  end


  def self.release(installer)
    lock = @@pid_files[pid_file(installer)]
    if lock
      lock.flock(File::LOCK_UN | File::LOCK_NB)
      lock.close
      File.delete(lock.path)
      @@pid_files.delete(pid_file(installer))
    end
  end


  def self.pid_file installer
    File.expand_path( File.join( installer.path, pid_file_name ) )
  end


  def self.cannot_lock_error_message installer
    "Another process (probably another builder) holds a lock on installer '#{ installer.name }'.\n" + "Look for a process with a lock on file #{ pid_file( installer ) }"
  end


  def self.already_locked_error_message installer
    "Already holding a lock on installer '#{ installer.name }'"
  end


  def self.pid_file_name
    "builder.pid"
  end
end
