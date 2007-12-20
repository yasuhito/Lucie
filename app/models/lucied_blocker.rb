class LuciedBlocker
  def self.block
    lock = File.open( pid_file, 'w' )
    locked = lock.flock( File::LOCK_EX | File::LOCK_NB )

    unless locked
      lock.close
      raise cannot_lock_error_message
    end
  end


  def self.blocked?
    unless FileTest.exists?( pid_file )
      return false
    end

    lock = File.open( pid_file, 'w' )
    begin
      return !lock.flock( File::LOCK_EX | File::LOCK_NB )
    ensure
      lock.flock( File::LOCK_UN | File::LOCK_NB )
      lock.close
    end
  end


  def self.release
    lock = File.open( pid_file, 'w' )
    if lock
      lock.flock( File::LOCK_UN | File::LOCK_NB )
      lock.close
      File.delete( lock.path )
    end
  end


  def self.pid_file
    "#{ RAILS_ROOT }/tmp/pids/#{ pid_file_name }"
  end


  def self.cannot_lock_error_message
    "Another lucied is already running."
  end


  def self.pid_file_name
    "lucied.pid"
  end
end
