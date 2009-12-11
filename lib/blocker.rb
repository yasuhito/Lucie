require "lucie"


class Blocker
  module PidFile
    def self.path name
      File.expand_path "#{ Lucie::ROOT }/tmp/#{ name }.pid"
    end


    def self.store name, pid
      File.open( path( name ), "w" ) do | file |
        file << pid
      end
    end


    def self.recall name
      IO.read( path( name ) ).to_i
    end
  end


  def self.start name = "lucie", &code_block
    begin
      block name
      code_block.call
    ensure
      release name
    end
  end


  def self.fork_start name = "lucie", &code_block
    block name
    PidFile.store name, Kernel.fork( &code_block )
  end


  def self.block name
    lock = File.open( PidFile.path( name ), "a+" )
    locked = lock.flock( File::LOCK_EX | File::LOCK_NB )
    unless locked
      lock.close
      raise "Another process is already running."
    end
  end


  def self.release name = "lucie"
    File.open( PidFile.path( name ), "w" ) do | lock |
      lock.flock( File::LOCK_UN | File::LOCK_NB )
      lock.close
      File.delete lock.path
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
