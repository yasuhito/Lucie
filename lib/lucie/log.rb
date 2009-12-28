require "logger"
require "singleton"


module Lucie
  class Log
    class SingletonLogger
      include Singleton


      FORMAT = "%Y-%m-%d %H:%M:%S"


      attr_reader :path


      def path= path
        @path = path
        @logger = ::Logger.new( @path )
        @logger.datetime_format = FORMAT
      end


      def method_missing message, *args
        @logger.__send__ message, *args if @logger
      end
    end


    def self.verbose= verbose
      SingletonLogger.instance.level = ( verbose ? ::Logger::DEBUG : ::Logger::INFO )
    end


    def self.method_missing message, *args
      SingletonLogger.instance.__send__ message, *args
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
