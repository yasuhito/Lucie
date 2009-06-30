require "configuration"
require "logger"
require "lucie/logger/null"
require "lucie/utils"


module Lucie
  module Logger
    class Installer
      LOG_FILE_NAME = "install.txt"


      def self.latest_log_directory node
        File.join log_directory( node ), "latest"
      end


      def self.latest_log node
        File.join latest_log_directory( node ), LOG_FILE_NAME
      end


      def self.latest_log_relative node
        File.join node.name, "latest", LOG_FILE_NAME
      end


      def self.log_directory node
        File.join Configuration.log_directory, node.name
      end


      def self.new_log_directory node, options, messenger
        labels = Dir[ "#{ log_directory( node ) }/install-*" ].collect do | each |
          /install-(\d+)\Z/=~ each 
          $1.to_i 
        end
        new_dir = File.join( log_directory( node ), "install-#{ labels.max ? labels.max + 1 : 0 }" )
        Lucie::Utils.mkdir_p new_dir, options, messenger
        Lucie::Utils.rm_f latest_log_directory( node ), options, messenger
        Lucie::Utils.ln_s new_dir, latest_log_directory( node ), options, messenger
        new_dir
      end


      def initialize directory, dry_run
        if dry_run
          @logger = Null.new
        else
          @logger = ::Logger.new( File.join( directory, LOG_FILE_NAME ) )
        end
      end


      def method_missing method, *args # :nodoc:
        @logger.__send__ method, *args
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
