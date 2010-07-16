module Lucie
  module Logger
    #
    # An empty logger. It can respond to logging methods (:info,
    # :debug, etc.), but it does nothing.
    #
    # Usage:
    #
    #   logger = Lucie::Logger::Null.new
    #   SSH.new( :logger => logger ).sh "macbook", "ls -1 /tmp"
    #
    class Null
      def method_missing method, *args # :nodoc:
        # do nothing.
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:


