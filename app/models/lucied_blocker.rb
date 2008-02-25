class LuciedBlocker
  # move to LuciedBlocker
  module PidFile
    def self.file_name
      File.expand_path "#{ RAILS_ROOT }/tmp/pids/lucied.pid"
    end

    def self.store pid
      File.open( file_name, 'w' ) do | f |
        f << pid
      end
    end

    def self.recall
      IO.read( file_name ).to_i rescue nil
    end
  end


  def self.block
    lock = File.open( PidFile.file_name, 'a+' )
    locked = lock.flock( File::LOCK_EX | File::LOCK_NB )

    unless locked
      lock.close
      raise cannot_lock_error_message
    end
  end


  def self.blocked?
    unless FileTest.exists?( PidFile.file_name )
      return false
    end

    lock = File.open( PidFile.file_name, 'a' )
    begin
      return !lock.flock( File::LOCK_EX | File::LOCK_NB )
    ensure
      lock.flock( File::LOCK_UN | File::LOCK_NB )
      lock.close
    end
  end


  def self.release
    lock = File.open( PidFile.file_name, 'w' )
    if lock
      lock.flock( File::LOCK_UN | File::LOCK_NB )
      lock.close
      File.delete( lock.path )
    end
  end


  def self.cannot_lock_error_message
    "Another Lucie daemon is already running."
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
