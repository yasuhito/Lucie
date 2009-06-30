require 'logger'


module Lucie
  class Log
    FORMAT = "%Y-%m-%d %H:%M:%S"


    @@logger = nil

    
    def self.path= path
      @@path = path
      @@logger = ::Logger.new( @@path )
      @@logger.datetime_format = FORMAT
    end


    def self.path
      @@path
    end
    

    def self.verbose= verbose
      return unless @@logger
      if verbose
        @@logger.level = ::Logger::DEBUG
      else
        @@logger.level = ::Logger::INFO
      end
    end


    def self.debug message
      return unless @@logger
      @@logger.debug message
    end


    def self.info message
      return unless @@logger
      @@logger.info message
    end


    def self.error message
      return unless @@logger
      @@logger.error message
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
